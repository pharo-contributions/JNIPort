# Sending messages to Java objects

Once you have [configured](jvm-configuration.md) and [started](starting-a-jvm.md) a Java VM, which is represented in Smalltalk by an instance of the class JVM, you can send messages to Java objects. Of course, you need a starting point: a reference to a Java class, which is the result by letting the JVM [find a class with a certain name](finding-a-java-class.md).

JNIPort creates Wrapper Classes for Java classes. It creates a Wrapper Method for each instance method, static method, and constructor. For each instance and static field, it creates an accessor method and a mutator method. The names of these generated methods follow simple rules:

- The selector of a method without arguments is just the Java method name.

  Example: `int currentTimeMillis()` becomes `#currentTimeMillis`.

- For the selector of a method with arguments, every keyword corresponds to the Java type name of the respective argument. The first keyword is composed of the method name, followed by an underscore (`_`), followed by the type name of the first argument.

  Example: `void shutdown(java.lang.String msg, boolean urgent)` becomes `#shutdown_String:boolean:`.

- The selectors of constructor messages are created in the same way, but the non-existant Java method name is replaced by new.

  Example: `#new`, `#new_StringBuffer:`.

- The selectors of field accessors are `#get_fieldName` and `#set_fieldName:` where `fieldName` is replaced by the actual name of the field.

In most cases, you can derive the selector directly from the JavaDoc documentation of the class which you want to use. However, there are cases where two or more methods of a Java class would result in the same selector for their Wrapper Methods. This happens when two methods differ only in their result type, but have the same name and parameters. JNIPort generates more complicated selectors in these cases. The details are described on this page: [Names of Generated Wrapper Methods](names-of-generated-wrapper-methods.md)

Here is an example:

```smalltalk
| jvm zfClass zipfile entries |
jvm := JVM current.
zfClass := jvm findClass: #'java.util.zip.ZipFile'.
zipfile := zfClass new_String: 'JNIPort.jar'.
zipfile size. "--> 15"
entries := zipfile entries.
[entries hasMoreElements] whileTrue: [| next |
  next := entries nextElement.
  Transcript print: next; cr
].