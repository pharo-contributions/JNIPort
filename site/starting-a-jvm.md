#Starting a JVM

## Starting a JVM from the JNIPort settings tool

To start a Java VM interactively in the VisualWorks development environment, first configure a JVMSettings in the [JNIPort settings tool](settings-tool.md). In the list pane of the settings tool, select the settings which you want to use. You can start the Java VM and create a JVM instance which represents it in Smalltalk by selecting Start Java VM from the context menu of the list pane.

## Starting a JVM programmatically

To start a Java VM programmatically, first [create an instance of JVMSettings](jvm-configuration.md), then send the message `newWithSettings:` to the class JVM using the settings as parameter:

```smalltalk
| settings jvm |
settings := JVMSettings new.
settings usesGhosts: true.
(settings jniPortSettings)
    jvmClass: JVMWithCallbacks;
    jniLibraryFilename: 'C:\Programs\Java\jre1.6.0_01\bin\client\jvm.dll'.
settings runtimeSettings classpath: '.;JNIPort.jar;JNIPort-Tests.jar'.
jvm := JVM newWithSettings: settings.
```

To start a JVM using the default JVMSettings, send newWithDefaultSettings to the class JVM:

```smalltalk
| jvm |
 jvm := JVM newWithDefaultSettings.
```

## Starting more than one JVM - not

Sun's Java VM implementation does not allow starting a second VM in the same operating system process. This limitation prevents using two or more JVMs in parallel, although the JNI's design supports this. This even holds true after the first JVM has been shut down. At development time, if you want to start a new JVM, you will have to save and restart the Smalltalk image. Java VM implementations from other vendors may not have this limitation.

When you try to start a second JVM, the JNI library will answer the error code -1 ("unknown error"). When you start a second JVM with a different jvm dynamic library, e.g. from a different version of Java, the JVM may start, but very probably raise errors later or even crash the whole operating system process.