
# JNIPort vs. JavaConnect

Johan Brichau has compared JavaConnect and JNIPort on the [JavaConnect home page](https://web.archive.org/web/20120331171815/http://www.info.ucl.ac.be:80/~jbrichau/javaconnect.html). However, there are some points where Joachim Geidel has a different view than Johan. The following remarks may not make much sense if you don't know JNIPort and JavaConnect already. You may want to read at least part of the documentation of the two frameworks first.

## Namespaces, classes, and Java class statics

JavaConnect lets you reference Java classes by simply writing their name into Smalltalk code, just as if it were a fully qualified Smalltalk class name. With JNIPort, you have to write the somewhat awkward "myJVM findClass: aJavaClassName" expressions to use a Java class. Code written for JavaConnect looks cleaner. However, this makes code less portable to other Smalltalk dialects, as Namespaces are currently a feature of VisualWorks only.

JNIPort implements two Smalltalk wrapper classes for a Java class, an "instance wrapper", and a "class wrapper" representing the static part of a Java class. Although it is tempting to simplify this by identifying the class static with the Smalltalk metaclass associated with the instance wrapper class, as it is done in JavaConnect, this can cause problems when different classes with the same name and package are loaded by distinct class loaders, e.g. class loaders using different class paths. Therefore, JNIPort does not create a single wrapper class for a Java class and does not add wrappers for static fields and methods as class methods. Instead, it creates a separate wrapper class.

## Settings and wrapper class generation

JavaConnect does not allow you to configure which methods (public, private, protected etc.) are generated in wrapper classes, and whether ghost classes are generated at all or only predefined wrapper classes are used. This is a design decision with the intention to make setup simpler, and Johan argues that it ensures that JavaConnect has the same settings whereever it is installed.

JNIPort lets you configure which methods to generate. This has two reasons:

- You can avoid to accidentally use private or protected methods and fields from Smalltalk. The JNI does not distinguish between them, so not generating wrapper methods for these methods can be kind of a (weak) protection against using the wrong methods.

- If you generate wrappers for public methods only, this reduces the amount of work which has to be done when generating a wrapper class on the fly, which may be good for your application's performance.

- If you generate predefined wrapper classes, you may not want to generate wrappers for private or protected methods if you don't need them.

Predefined wrapper classes are the way to go if you want to add Smalltalk methods to Java classes in JNIPort. As they are regular Smalltalk classes, they can be versioned with Store and published as parcels as usual. If all of the Java classes which you need have predefined wrapper classes, you can switch off ghost class generation in JNIPort. At runtime, there will be less work to do. While it should not make a noticeable performance difference in most cases, your mileage may vary. JavaConnect has a different mechanism for adding methods to Java classes and always generates ghost classes.

In addition to the settings for code generation, JNIPort has several other options. For example, you can add any Java VM command line option supported by the Java runtime environment, you can monitor debugging output from the JVM, and use the abort and exit hooks offered by the Java VM.

## Performance

Johan Brichau and Joachim Geidel also compared the [relative performance of some code snippets](jniport-javaconnect-performance-comparison.md) in JNIPort and JavaConnect. Please don't let the numbers impress you too much: Performance may change with every JNIPort, JavaConnect or Java Runtime Environment version released, and performance is not everything that counts. The code snippets which have been measured are in no way similar to what a typical application does: Applications typically don't look up the same class a million times in a row, or create a million new instances of some class only to immediately forget about them. Also, the few microseconds for a call from Smalltalk to Java are not very likely to have much impact on most applications. If they do in your case, consider changing the design of your code - you are crossing the boundary between Smalltalk and Java much too often! See what other people offering in-process integration of Java [say about this topic](https://web.archive.org/web/20210419035719/http://codemesh.com/in_process.html).

## Thread safety and canonical instances

JNIPort's internal data structures are thread safe in the sense that concurrent Smalltalk processes can use the JVM and access Java. The critical parts are protected by RecursionLocks which ensure that a Process altering an internal data structure like the class registry does not interfere with other Processes. For example, two processes which have looked up the same Java class can't accidentally insert two different wrappers into the JVM's class registry.

JavaConnect currently does not protect its data structures against such problems. If your application accesses Java from a single Smalltalk process only, this is no problem. If your code has concurrent processes, you can always use Semaphores or RecursionLocks in your own code for synchronisation - but it is not automatic.

The downside of protecting JNIPort's data structures by RecursionLocks is that this has a performance impact. Johan has run performance comparisons of several code snippets, where he found that JNIPort is slower when classes are configured such that they have "canonical instances". What does this mean? If a class has canonical instances, it ensures that a Java object is represented by exactly one Smalltalk object (an instance of a subclass of JavaObject). To do this, such a class uses a JavaObjectRegistry, which wraps a WeakSet of known instances. JavaConnect does this by default, every wrapper class uses such a registry. The main difference is that JNIPort uses a thread safe subclass of WeakSet, and this is the root of the performance degradation when using canoncial instances. Protecting access to the classes' registries by RecursionLocks slows down the retrieval of Java objects considerably.

Therefore, JNIPort does not use canonical instance by default. In most cases, it is not important that Java objects may be represented by more than one wrapper object. Just keep in mind that you have to compare wrappers by using the messages `#=` or `#isSameAs:` for comparison, and that in most cases it is not appropriate to store JavaObjects in IdentitySets or use them as keys in IdentityDictionaries. Apart from this, there shouldn't be any problems with the fact that you can't test for identity of Java objects by sending `#==` to their wrapper objects. If you need this feature for some class, you can still use canonical instances for this class.

If you protect access to JavaConnect by using Semaphores or RecursionLocks in your own code, you are going to protect much larger blocks of code than in JNIPort. The overhead for executing critical sections will be less than in JNIPort, but other processes will have to wait longer until they can continue.
Callbacks and Threads

Because of the [problems with threads](problems-with-threads.md), callbacks from Java to Smalltalk are quite complicated in JNIPort. Setting up a callback in JNIPort is no fun, unfortunately.

On the other hand, the much simpler implementation in JavaConnect 2.0-beta currently has two problems:

- Callbacks are stored in a Dictionary which is keyed by the identity hashes of the receivers of callback messages. This will lead to problems when two objects have the same identity hash - one of them will receive messages intended for another object, leading to bugs which will be hard to debug, because they are probably not reproducible. The same holds for wrapped Smalltalk exceptions, which are also stored in a Dictionary with identity hashes as keys. This is actually a bug in JavaConnect 2.0-beta, and hopefully it will be fixed.

- If callbacks come from a "foreign" native thread (a thread different from the one in which Smalltalk code are executed), e.g. when using JavaConnect's ThreadedJavaVM, they will be executed in a separate Smalltalk process which runs at a high priority (Processor lowIOPriority - 5). This process can interrupt lower priority processes which access JavaConnect's data structures. As there is no protection of critical sections of code, you have to implement your own synchronisation mechanism if your callback calls JNI functions, e.g. if it has to access any fields of a Java object which contain Java objects (including instances of java.lang.String). If only one Smalltalk process interfaces to Java, and only one native thread calls back into Smalltalk, JavaConnect's implementation is sufficient.

JavaConnect's ThreadedJavaVM, which uses threaded calls to JNI and therefore does not block other Smalltalk processes, is indeed a nice feature which JNIPort does not offer currently. However, be careful when using it.
