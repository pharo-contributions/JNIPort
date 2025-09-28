# Quick Start

What you have to do

To use Java from your Smalltalk application, you have to

- [Download JNIPort](file-cabinet.md) and load it into your Smalltalk image
  - Create a JVMSettings object which tells JNIPort where the Java VM library file is,
  - Create a JVM object which loads the Java VM and represents it in Smalltalk,
  - Find Java classes as entry points into the Java world,
  - Send messages to Java objects.

Each of these steps is described in more details in the [Getting started](jniport-for-visualworks.md) section of this wiki. We skip all of the details here and walk through a short example which you can copy into a Workspace and evaluate there. Variable declarations are omitted for brevity.

## Create a JVMSettings object

The following code is the absolute minimum for creating a JVMSettings object.

```smalltalk
settings := JVMSettings new.
settings usesGhosts: true.
(settings jniPortSettings)
  "we do not use callbacks from Java to Smalltalk in this example"
  jvmClass: JVMWithoutCallbacks;
  "tell JNIPort which Java VM library to use"
  jniLibraryFilename: 'C:\Programs\Java\jre1.6.0_01\bin\client\jvm.dll'.
```

The usesGhosts property tells JNIPort to dynamically create wrapper classes ("ghost classes") for each Java class it encounters. When JNIPort operates in this mode, you can send messages to instances of a Java class in a simple way. For a Java class, JNIPort will create a Smalltalk class at runtime with methods for the members (method, field, constructor) of the Java class. It is possible to work without ghost classes, but then you either have to generate wrapper classes up front, or send messages to Java objects which do not have a Smalltalk wrapper class in a slightly more complicated way. So, just set it to true for now.

The Java VM is a shared library which is installed as part of the Java Runtime Environment. Its name depends on the operating system and possibly on the vendor. In Sun's Java Runtime Environment, the name is `jvm.dll` on Windows, `libjvm.so` on Linux, and `libjvm.dylib` on MacOS-X. It is not `java.exe` or `java`. The path to the library depends on where you installed the Java Runtime Environment, you will have to look it up on your system.

## Creating a JVM object

You create a JVM object by sending a message to the class JVM, with a JVMSettings instance as parameter. This will load the Java VM library and start a Java VM. The JVM instance is your interface to the Java VM. It is used to look up Java classes, and shut down the Java VM when it is no longer needed.

```smalltalk
jvm := JVM newWithSettings: settings.
```

## Finding a Java class

To look up a Java class and dynamically create a Smalltalk wrapper class for it if there is no predefined wrapper class, send the message #findClass: to the JVM. The method will answer with a proxy for the Java class.

```smalltalk
zfClass := jvm findClass: #'java.util.zip.ZipFile'.
```

## Sending messages to Java objects

When JNIPort has created the ghost class for java.util.zip.ZipFile, it has also generated a Smalltalk method for every method in the Java class. By default, only public methods are wrapped. If you need access to private or protected methods, you have to configure this in the ghostClassSettings which are part of the JVMSettings.

The following is an abridged version of the page titled "Wrapper-class Examples" in Chris Uppal's JNIPort documentation.

The wrapper class will have the following instance methods:

- #close
- #entries
- #getEntry_String:
- #getInputStream_ZipEntry:
- #getName
- #size

The class also has three class-side methods, all of which are wrappers for constructors:

- #new_File:
- #new_File:int:
- #new_String:

Using one of the Constructor methods, we create a new instance of the ZipFile class which represents the JNIPort.jar file included in the JNIPort download:

```smalltalk
zipfile := zfClass new_String: 'JNIPort.jar'.
```

We can now send messages to this object:

```smalltalk
zipfile size. "Answers the number of files in the ZipFile."
```

Now we'll iterate over the elements of the ZipFile; we start by getting the Java java.util.Enumeration iterator:

```smalltalk
entries := zipfile entries.
```

The entries object is an instance of some Java class that implements the java.util.Enumeration interface, (for some reason, ZipFile returns a Enumeration rather than the newer Iterator); it is actually an instance of some inner class in ZipFile (so its class name is something like `java.util.zip.ZipFile$2`). It has the Java methods `hasMoreElements()` and `nextElement()` that are guaranteed by the interface. Since we are using ghost classes, a new ghost class will have been created for the enumeration object, and it will have corresponding wrapper methods #hasMoreElements and #nextElement. So we could iterate over the entries with a loop like:

```smalltalk
entries := zipfile entries.
[entries hasMoreElements] whileTrue: [| next |
  next := entries nextElement.
  Transcript display: next; cr
].
```

But that isn't very Smalltalkish. JNIPort comes with a better way to iterate over a Enumeration (or an Iterator). Sending #asAnEnumeration (or #asAnIterator) to the entries object will answer an adaptor that implements the basics of the <ReadableStream> protocol. You can then use the common Smalltalk iteration style:

```smalltalk
entries := zipfile entries asAnEnumeration.
[entries atEnd] whileFalse:
  [Transcript display: entries next; cr].
```

or, if you prefer:

```smalltalk
entries := zipfile entries.
entries asAnEnumeration do:
  [:each | Transcript display: each; cr].
```

By the way, the adaptor object only implements a small part of the Smalltalk <ReadableStream> protocol. You can get a more complete implementation by either writing the other wrapper methods yourself <grin> or by asking for a further level of adaptor by sending #asReadStream.