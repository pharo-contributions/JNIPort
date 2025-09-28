# JavaRuntimeSettings

The JavaRuntimeSettings let you configure the class path which the Java VM will use to locate class files, and the library path which the Java VM uses to find dynamic libraries which implement native methods. The JavaRuntimeSettings also define the options which are passed to the Java VM. For an overview of VM options, consult the Java VM documentation or this inofficial page. It is not necessary to enter any options for starting a Java VM.

Both the class path and the library path are lists of paths to directories or jar files, where the list elements are separated by a separator character. Please note that the character which is used to separate the paths in both lists is a semicolon (`;`) on Windows and a colon (`:`) on Linux, MacOS-X and other Unix-like platforms. Please consult the Java documentation or the Wikipedia page on the Java Classpath for more details.

If you need callbacks from Java to Smalltalk, the file JNIPort.jar has to be in the class path. To run the JNIPort tests, both JNIPort.jar and JNIPort-Tests.jar have to be in the class path. To get started, the simplest configuration is to copy JNIPort.jar and JNIPort-Tests.jar into the directory where your VisualWorks image is stored, and add both filenames to the class path. The JavaRuntimeSettings are accessed by sending runtimeSettings to an instance of JVMSettings.

Code snippets

```smalltalk
| runtimeSettings |
runtimeSettings := JVMSettings default runtimeSettings.
runtimeSettings classpath: '.;JNIPort.jar;JNIPort-Tests.jar'.
"Set the library path to nil if it is not needed. This is the default, you don't have to do this explicitly."
runtimeSettings libpath: nil.
runtimeSettings addOption: '-verbose:jni'.
runtimeSettings addOption: '-verbose:class'.
```