# Configuring a JVM programmatically

In a runtime system, you have to create a configuration for the JVM programmatically instead of using the JNIPort settings tool. You can create any number of predefined configurations and use one of them for starting a JVM, or you can create a configuration on the fly when your application starts a JVM.

The configuration of a JVM is implemented by the class JVMSettings. This class stores a template which is copied to create a new instance. The class also registers named instances which can be used to start a JVM.

Here is an example for creating a JVMSettings instance, which is then used to start a new JVM:

```smalltalk
| settings jvm |
"Create a new predefined instance of JVMSettings."
settings := JVMSettings new.
settings usesGhosts: true.
(settings jniPortSettings)
  jvmClass: JVMWithCallbacks;
  jniLibraryFilename: 'C:\Programs\Java\jre1.6.0_01\bin\client\jvm.dll'.
settings runtimeSettings classpath: '.;JNIPort.jar;JNIPort-Tests.jar'.
(settings ghostClassSettings)
  includePrivateMethods: true;
  retainMethodSource: true.
jvm := JVM newWithSettings: settings.
```

You have to set the jvmClass, the jniLibraryFilename, and the classpath for a minimal configuration. You should also set usesGhosts to true unless you have a reason not to use ghost classes. This should be sufficient to use Java classes in almost all cases.

There are many more options available which control different aspects of the interface to the Java VM. These details are described on the following pages:

- [The class JVMSettings](jvmsettings.md)
- [The JNIPortSettings](jniportsettings.md)
- [The JavaRuntimeSettings](javaruntimesettings.md)
- [The JavaWrapperGeneratorSettings](javawrappergeneratorsettings.md)
- [The JavaGhostClassGeneratorSettings](javaghostclassgeneratorsettings.md)
- [The SupplementaryClassloadersSettings](supplementaryclassloaderssettings.md)