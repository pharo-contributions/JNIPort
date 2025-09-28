# Problems and Limitations

## Stability issues

JNIPort is based on the “real” Java runtime. That has great advantages in terms of performance and compatibility. It brings corresponding disadvantages in the way that the Smalltalk process is exposed to the whims and derelictions of the implementers of the Java runtime — which is, after all, just a DLL.

Unfortunately, that means that using JNIPort can crash a Smalltalk image. Using the Sun JVMs, the problem has grown smaller and smaller with each successive release, but there still are very occasional crashes:

- The biggest problem is, and probably always will be, java.lang.System.exit(). There are only three ways to deal with Java code that calls this pernicious method:

  - Do nothing; just hope that nothing will call exit(). If it does then the Smalltalk process will also exit. You have no chance to save data. Actually this approach does work fairly well in practice, but is obviously not a perfect solution.
  - Use the JNI exit “hook” to trap and ignore attempts to exit(). This ought to work, but does not with any implementation which has been tried so far. Sun's JVMs up to 1.4.0 used to deadlock if you provided an exit hook that didn't exit. 1.4.1 has improved the picture slightly, and it now hits an internal breakpoint (see below) instead.
  - Use Java's internal security policies to forbid all calls to exit(); that might work, but it hasn't been tried yet in combination with JNIPort.

- The JVM - at least in some versions - is not written such that it can be a part of a bigger application without problems. It contains breakpoints in the code rather than returning errors. Probably the reasoning is that the JVM is no longer in a trustworthy state, so it's best just to exit. This does not consider the possibility that the rest of the application might be able to continue, at least enough to allow you to save data, etc. The symptom is that on Windows, you get a Windows error message telling you that a breakpoint has been reached, and giving you the option of killing the process (the default) or debugging it (not sure what happens on other platforms). Chris Uppal has sometimes been able to continue for a little while by letting the system start the debugger (MS VC++ in my case) and using it to “continue” the application. The Dolphin IDE, e.g., is in a decidedly unstable state by that point, though, so it's better not to do more than save any work, and perhaps do a little debugging to see how the breakpoint was triggered.

- Any complex code can have problems; the earlier Sun JVMs have a history of problems with floating point handling, for instance. Since Smalltalk and the JVM are sharing a process space, Smalltalk is exposed to any bugs in the Java VM's implementation. In general the latest JVMs are pretty stable. See the [notes on individual JVMs](compatibility.md) for other information about specific problems with individual vendor's products.

Most current Java VMs for Windows use operating-system threads. (They may multiplex more than one Java thread onto an OS thread, but that doesn't affect this issue, except possibly to make it worse). Dolphin and VisualWorks execute all Smalltalk code on just one OS thread. This mismatch of models is described in the [problem with threads](problem-with-threads.md). It causes a number of problems, most significantly it means that JNIPort uses some very slow and restricting workarounds to allow any callbacks from Java to Smalltalk at all. Even with the workarounds, it is possible to create situations that deadlock. They can be avoided by taking sufficient care, but it's difficult to get right (even more difficult than avoiding deadlocks in normal threaded code, which is challenging enough in itself). The simple solution is not to use callbacks and Java threads together.

One last point under this heading: The maintainers of JNIPort do not have the resources for extensive testing. But JNIPort is a fairly large piece of software; if we had tested to the extent that we'd wish (either out of a programmer's natural desire to do a good job, or in our other role as users of JNIPort) then it'd still be ages away from first release.

## Performance issues

The biggest curable issue with JNIPort performance was that creating ghost classes can be relatively slow. This isn't so much because it takes a long time to create a ghost class, but because creating a ghost for one class means that all other classes that it refers to (method parameters, and so on) also get imported. Since these other classes also have ghost classes created for them, the process only stops when the transitive closure of the inter-class references have all been loaded. In theory that could load every class on the planet. In practice, the worst case which has been encountered in practice is Swing, where referring to any one class is likely to drag in a large fraction of Swing — several hundred classes.

Therefore, switching to a less eager scheme for creating ghost classes was Chris Uppal's single highest priority for the future of JNIPort for Dolphin. Actually that is available for Dolphin, if you use a JVMLazyGhostClassMaker instead of an JVMGhostClassMaker — the feature is still experimental, though. JNIPort for VisualWorks implements a different technique, which avoids calling the Smalltalk Compiler for creating methods, and copies prototype methods instead. This technique was adopted from Johan Brichau's [JavaConnect](jniport-vs-javaconnect.md).

Callbacks from Java into Smalltalk could never be very convenient, since the JNI model is that all callbacks are implementations of “native” methods (so there is no instance-specific behaviour, and no natural equivalent of a function pointer). However, because of the the problem with threads, JNIPort can't even make full use of that (basically because it can't pass any object references across the interface from Java up into Smalltalk). Therefore JNIPort includes a workaround that allows Java code to construct and enqueue “request” objects that hold the parameters and return value of a callback. The only data that passes from Java to Smalltalk is a notification that the queue of requests is not empty, the rest of the process of serving the requests is driven from Dolphin (calling down into Java). This works but is not convenient for the programmer; nor is it quick. In fact it is very slow: in the millisecond range and up, which is too slow for many applications. Currently, there are no ideas at all about how this could be improved.

Whenever a new reference to a Java object enters the JNIPort system, it must generate a wrapper object. The lookups involved in finding the right classes mean that the performance is less than stellar. Wrapping a reference can take microseconds — which is quite a long time by computer standards. It might be possible to use some sort of lazy wrapping scheme to reduce the overhead, or perhaps some kind of cache, but we haven't investigated either the feasibility or the potential benefits yet. We don't see this as high priority.

## Functional issues

Probably the single most irritating thing about JNIPort (in a development context) is that you can't either run different Java runtimes at the same time, or stop the current one and start a new one. This comes down to Sun's / Oracle's failure to implement their own published APIs (though all the other JVMs tested have the same failings). There's nothing that can be done about it; if you want to start a new Java runtime, then you have to quit and restart Smalltalk.

Currently there is no way to unload a reference to a Java class. Once JNIPort has seen a reference to it (say because it's seen an instance of a subclass) it will hold onto that reference until the Java runtime is shut down. This prevents the class being garbage collected by Java. The issue may be trivial for some potential applications of JNIPort, but it directly affected Chris Uppal's own work. Actually that is available, if you use a “supplementary classloader” — the feature is still experimental, though.

The methods in category 'documentation' on the class-side of JVM contain some more notes about bugs and deficiencies in the current version of JNIPort.

If you happen to think that “generics” in Java are a good idea then you may be disappointed to find that JNIPort doesn't support them. In fact it can't, because generics are a fiction created entirely as a hack in the Java compiler, and are not seen by the Java runtime at all. Since JNIPort talks to the Java runtime, and has nothing whatever to do with the Java compiler, it can only see and manipulate the real classes, objects, and methods.

## Other issues

The documentation is not complete. It probably never will be. Live with it.