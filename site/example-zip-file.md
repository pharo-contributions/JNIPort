# Example - Accessing a ZIP file

The example reads a .ZIP file using Java's zip file handling classes.

One general point about this example: we use the generated wrapper methods directly throughout, which is probably not how you would want to use them in practice. The better way is to define wrapper classes and provide convenient Smalltalk-style methods that are built on top of the automatically generated ones. 

JNIPort does not include wrappers for all the Java classes used in this example so, unless you have generated them yourself, JNIPort should be configured to use ghost classes. You should also have the 'CU Java Additional Wrappers' package installed, since that defines some of the adaptors that we will use.

Ensure that a properly configured JVM is running, and open a new workspace. We start, as always, by getting a reference to the JVM object:

```smalltalk
jvm := JVM current.
```

Now we need to get a reference to the class static standing for the Java class, `java.util.zip.ZipFile`:

```smalltalk
zfClass := jvm findClass: #'java.util.zip.ZipFile'.
```

Take a look at the Java Classes Browser which will show what generated wrapper methods are available. The browser can be opened from the JNIPort submenu of the VisualWorks Launcher's Tools menu. It should show that there are six instance-side methods:

- #close
- #entries
- #getEntry_String:
- #getInputStream_ZipEntry:
- #getName
- #size

There are three class-side methods, all of which are wrappers for constructors:

- #new_File:
- #new_File:int:
- #new_String:

And lots of getter methods for the integer constants defined by the class.

You might want to review the JavaDoc documentation for `java.util.zip.ZipFile`.

Dolphin Smalltalk only: If you have configured the JavaDoc root property of the Status Monitor (in the 'Tools⇒Options' menu) then you should be able to launch a browser directly onto the JavaDoc file by pressing F12 or selecting 'Browse JavaDoc' from the 'Class' menu. You will have to have installed the Java documentation for this to work; the JavaDoc root should be set to the api/ directory under the docs/ installation folder.

Now we'll open a ZIP file. For this example, we'll use the DolphinJNIHelper.zip file that should be in the Extras folder of the JNIPort for Dolphin Smalltalk download, or in the `JNIPort_Extras.zip` archive. Use the file dialog to find that file:

```smalltalk
zfName := 'Extras\DolphinJNIHelper.zip'.
```

Now we create a new ZipFile object from that filename:

```smalltalk
zipfile := zfClass new_String: zfName.
```

In this case we passed a Smalltalk String object to the ZipFile constructor that expected a java.lang.String and the Smalltalk String was converted automatically. That conversion only works for Strings and primitive types.

We may as well find out how many entries there are in the ZIP file:

```smalltalk
zipfile size. "--> 6"
```

Now we'll iterate over the elements of the ZipFile; we start by getting the Java `java.util.Enumeration iterator`:

```smalltalk
entries := zipfile entries.
```

The entries object is an instance of some Java class that implements the java.util.Enumeration interface, (for some reason, ZipFile returns a Enumeration rather than the newer Iterator); it is actually an instance of some inner class in ZipFile (so its class name is something like `java.util.zip.ZipFile$2`). It has the Java methods hasMoreElements() and nextElement() that are guaranteed by the interface. Since we are using ghost classes, a new ghost class will have been created for the enumeration object, and it will have corresponding wrapper methods #hasMoreElements and #nextElement. So we could iterate over the entries with a loop like:

```smalltalk
entries := zipfile entries.
[ entries hasMoreElements ] whileTrue: [ | next |
  next := entries nextElement.
  Transcript display: next; cr
].
```

But that isn't very Smalltalkish. Also it depends on the fact that we are using ghost classes. JNIPort comes with a better way to iterate over a Enumeration (or an Iterator). Sending #asAnEnumeration (or #asAnIterator) to the entries object will answer an adaptor that implements the basics of the <ReadableStream> protocol. You can then use the common Smalltalk iteration style:

```smalltalk
entries := zipfile entries asAnEnumeration.
[ entries atEnd ] whileFalse: [
  Transcript display: entries next; cr
].
```

or, if you prefer:

```smalltalk
entries := zipfile entries.
entries asAnEnumeration do:[ :each |
  Transcript display: each; cr
].
```

By the way, the adaptor object only implements a small part of the Smalltalk <ReadableStream> protocol. You can get a more complete implementation by either writing the other wrapper methods yourself <grin> or by asking for a further level of adaptor by sending #asReadStream.

Another way to get a Smalltalk-style adaptor is to use JavaIteratorAdaptor or JavaEnumerationAdaptor (which are subclasses of ReadStream), but they only work with adaptees that use the JNIPort rules for the names of generated methods, which — in practise — means that they only work if you are using ghost classes.

Now to read one of the files from inside the ZipFile. We start by getting the appropriate ZipEntry:

```smalltalk
file := 'DolphinJNIHelper/DolphinJNIHelper.h'.
entry := zipfile getEntry_String: file.
entry getSize. "--> 2581"
```
If you check the class in the Java Classes Browser then you'll see that you can ask the ZipEntry for a fair raft of data. What you can't do is get the contents of the file, for that you have to go back to the ZipFile (that's just the way the Java class is designed), so:

```smalltalk
stream := zipfile getInputStream_ZipEntry: entry.
```

This answers an object that is of some subclass of java.io.InputStream. Because there is a registered wrapper class for InputStream, actually JavaIoInputStream, the stream object will be an instance of some subclass of that. The mismatch between Java's IO design and Smalltalk's is quite bad, and thus JNIPort does not provide a completely Smalltalk-flavoured interface to Java streams, however you can ask the stream for its #upToEnd (you can't use #contents because that requires a positionable stream and Java's streams aren't arbitrarily seekable). Since the stream in question is binary, the answered collection will be a ByteArray. So we can get the contents of the file by saying:

```smalltalk
bytes := stream upToEnd.
Transcript nextPutAll: bytes asString; flush.
```
That's almost the end of the example. We may as well clean up properly, though:

```smalltalk
zipfile close.
```

Finally, to see an example of what happens when Java code throws exceptions, try getting a ZipEntry again now that the ZipFile has been closed:

```smalltalk
zipfile getEntry_String: 'xxx'
```

Which should give a normal Smalltalk walkback. You can trap the error in various ways, one is:

```smalltalk
[
  zipfile getEntry_String: 'xxx'
] on: JavaException do: [:err |
  err notify
].
```

Another:
```smalltalk
exClass := jvm findClass: #'java.lang.IllegalStateException'.
[
  zipfile getEntry_String: 'xxx'
] on: exClass do: [:err |
  Transcript display: 'Too bad'; cr
].
```
