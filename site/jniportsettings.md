# JNIPortSettings

The JNIPortSettings define which Java VM library is used, whether callbacks from Java to Smalltalk will be supported, and if JNIPort uses certain hooks of the JNI for capturing debugging output of the Java VM. The JNIPortSettings are accessed by sending jniPortSettings to an instance of JVMSettings. To determine whether the JVM will support callbacks from Java to Smalltalk, you have to set the JVM class of the JNIPortSettings. If you do not need callbacks from Java to Smalltalk, use the class JVMWithoutCallbacks. If you intend to use callbacks, use JVMWithCallbacks. You have to set the filename of the library which implements the Java VM.

The JNIPortSettings has several boolean flags which control if the JNIPort uses certain hooks of the JNI for capturing debugging output of the Java VM. They are discussed elsewhere. For normal operation, you can use the default values or set all of them to false, which means that none of the hooks are used. In a runtime system, the hooks are usually not needed. They are most useful for debugging.

## Code snippets

```smalltalk
| jniPortSettings |
jniPortSettings := JVMSettings default jniPortSettings.
jniPortSettings jvmClass: JVMWithCallbacks.
jniPortSettings jniLibraryFilename: 'C:\Programs\Java\jre1.6.0_01\bin\client\jvm.dll'.
jniPortSettings setFlags: 0. "The quick way to switch off all flags controlling the JVM hooks."
 ```

The Java VM is a shared library which is installed as part of the Java Runtime Environment. Its name depends on the operating system and possibly on the vendor. In Sun's Java Runtime Environment, the name is `jvm.dll` on Windows, `libjvm.so` on Linux, and `libjvm.dylib` on MacOS-X. It is not `java.exe` or `java`. The path to the library depends on where you installed the Java Runtime Environment, you will have to look it up on your system.