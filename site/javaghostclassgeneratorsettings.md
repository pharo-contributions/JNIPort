# JavaGhostClassGeneratorSettings

The `JavaGhostClassGeneratorSettings` configure the code generator which is used to generate wrapper classes for a Java class which are created on the fly when an instance of a Java class is encountered. They let you control in detail which methods and fields of a Java class are made accessible by generating Smalltalk methods for them. The default settings generate methods for public methods, fields, and constructors. The JNI lets you use private and protected methods and fields too. The different flags are explained in the comments of the methods in the 'accessing' protocol of JavaGhostClassGeneratorSettings. The JavaGhostClassGeneratorSettings are accessed by sending `ghostClassSettings` to an instance of `JVMSettings`.

There is flag called `retainMethodSource`. By default, the source code of dynamically generated methods is discarded after compilation. For debugging the code generator, it can be useful to keep the source code by setting this flag to true.

These settings are used at runtime. Use the default settings unless you really need to generate additional methods for private or protected members of Java classes, and do not want to implement a predefined wrapper class for the classes in question.

Code snippets

```smalltalk
| ghostClassSettings|
ghostClassSettings:= JVMSettings default ghostClassSettings.
ghostClassSettings includePrivateMethods: true.
ghostClassSettings retainMethodSource: true.
```