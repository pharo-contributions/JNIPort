# Configuring a JVM in the JNIPort Settings Tool

You can configure and start a Java VM interactively using the JNIPort Settings Tool. The settings tools helps you to get started with JNIPort in your development environment. It is not intended for a runtime environment, where you have to configure and start the Java VM programmatically.

## Opening the JNIPort Settings Tool

You can open the JNIPort Settings Tool from the Tools menu of the VisualWorks Launcher.


The menu item "JNIPort Settings" will open the tool, which initially shows one predefined configuration for a Java VM.

## Configuring a JVM

### The JVM settings

The settings for a JVM configuration have a hierarchical structure. At the top level, you can define a name for the configuration, and select whether the JVM will generate "ghost classes". Ghost classes are Smalltalk classes which act as wrappers for Java classes, and which are generated on the fly whenever an instance of a Java class is encountered for which no wrapper class has been defined. It is possible to work without ghost classes, but it is easier to get started by selecting "Generate ghost classes".

### The JNIPort settings

The next thing which you have to do is defining the "JNIPort settings" for the JVM configuration.


First, you have to select the JVM class. If you do not need callbacks from Java to Smalltalk, select "JVMWithoutCallbacks". If you intend to use callbacks, select "JVMWithCallbacks".

Second, you have to enter the filename of the library which implements the Java VM. The Java VM is a shared library which is installed as part of the Java Runtime Environment. Its name depends on the operating system and possibly on the vendor. In Sun's Java Runtime Environment, the name is `jvm.dll` on Windows, `libjvm.so` on Linux, and `libjvm.dylib` on MacOS-X. It is not `java.exe` or `java`. The path to the library depends on where you installed the Java Runtime Environment, you will have to look it up on your system. You can use the Browse... button to open a file dialog for selecting the libary.

The check boxes on this page control if the JNIPort uses certain hooks of the JNI for capturing debugging output of the Java VM. For normal operation, you can leave them unchecked.

### The Runtime settings

The runtime settings let you configure the class path which the Java VM will use to locate class files, and the library path which the Java VM uses to find dynamic libraries which implement native methods. Both are lists of paths to directories or jar files, where the list elements are separated by a separator character. Please note that the character which is used to separate the paths in both lists is a semicolon (`;`) on Windows and a colon (`:`) on Linux, MacOS-X and other Unix-like platforms. Please consult the Java documentation or the [Wikipedia page on the Java Classpath](https://en.wikipedia.org/wiki/Classpath) for more details.

If you need callbacks from Java to Smalltalk, the file JNIPort.jar has to be in the class path. To run the tests, both JNIPort.jar and JNIPort-Tests.jar have to be in the class path.

To get started, the simplest configuration is to copy `JNIPort.jar` and `JNIPort-Tests.jar` into the directory where your VisualWorks image is stored, and add both filenames to the class path.

### The Java VM options

The Java VM options are a sub-setting of the Runtime settings. On this page, you can enter a list of options for the Java VM. For an overview of VM options, consult the Java VM documentation. If you are working on Mac OS X with Apple's Java implementation, see Apple's documentation of Java Virtual Machine Options. It is not necessary to enter any options for starting a Java VM.

### The Wrapper generator settings

The Wrapper generator settings configure the code generator which is used to generate predefined wrapper classes for a Java class. They let you control in detail which methods and fields of a Java class are made accessible by generating Smalltalk methods for them. The default settings generate methods for public methods, fields, and constructors. The JNI lets you use private and protected methods and fields too. If you really need this, you can check the appropriate check boxes before generating a wrapper class.

These settings are only used at development time. Use the default settings unless you really need to generate additional methods.

### The Ghost class settings

The Ghost class settings configure the code generator which is used to generate wrapper classes for a Java class which are created on the fly when an instance of a Java class is encountered. They let you control in detail which methods and fields of a Java class are made accessible by generating Smalltalk methods for them. The default settings generate methods for public methods, fields, and constructors. The JNI lets you use private and protected methods and fields too, so if you really need this, you cancheck the appropriate check boxes before generating a wrapper class.

There is also a check box called retainMethodSource. By default, the source code of dynamically generated methods is discarded after compilation. For debugging the code generator, it can be useful to keep the source code by checking this option.

These settings are used at runtime. Use the default settings unless you really need to generate additional methods for private or protected members of Java classes, and do not want to implement a predefined wrapper class for the classes in question.

### Supplementary Classloaders

In this section, you can define additional classloaders together with their class path. See the class comment of SupplementaryClassloaderTree for more details.

## Additional Configurations

You can define as many configurations as you like. E.g., you can define a configuration for each version of the Java Runtime Environment which you have installed. The context menu of the list pane in the settings tool lets you add and remove configurations. The configurations can also be saved to or read from the registry, which is the Windows registry on Windows, and a directory called .registry in your home directory on other platforms.