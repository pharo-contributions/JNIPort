# Debugging

## Java VM crashes

- Due to a bug of Sun's Java 5 VM, using the Java VM option `-Xcheck:jni` will lead to fatal errors in the Java VM. If you use the JVM abort hook, it will be reported to VisualWorks before the JVM exits. Unfortunately, this will terminate the VisualWorks process as well. The problem is fixed in Java 6. So, if you are using Sun's Java 5 VM, don't use `-Xcheck:jni`. The problem does not exist in Sun's Java 6 implementation.

- The Java VM may crash when it uses Java classes from a different Java version. E.g., the Sun JRE 1.6 Java VM crashes when it uses class files from the Sun JRE 1.5.

  - Check that the classpath is correct. Also check the `CLASSPATH` environment variable.

  - To verify that the VM loads the right classes, monitor which classes are loaded by using the [Java VM hook](monitoring-jvm.md) for debugging messages.

- You can inspect the properties of the Java runtime to check that they match your expectations:

  ```Smalltalk
  | systemStatic |
  systemStatic := JVM current findClass: 'java.lang.System'.
  "Access a single property..."
  Transcript cr; show: (systemStatic getProperty_String: 'java.runtime.name'); cr.
  "...or simply inspect them all in a Smalltalk Inspector."
  systemStatic getProperties inspect.
  ```

- Mac OS X on a PowerPC based Mac: It seems that the Java VM of the Mac OS X JDK on PowerPC tries to call back into the host program using an API which is not supported by the VisualWorks VM (VisualWorks 7.6 and later). If you want to use JNIPort on this platform, try using another JVM implementation.

- JamVM with the Gnu Classpath libraries is known to work with JNIPort on PowerPC. See the [instructions for this configuration](mac-os-x-10-5-powerpc.md).

JNIPort may have a bug. Unlikely ;-) but possible.

## NoClassDefFoundError

When the Java VM cannot find a class, it raises a NoClassDefFoundError which is wrapped in a JavaException by the JVM. For example, the following code:

```
JVM current findClass: 'java.lang.xyz'
```

will result in

> Unhandled exception: Uncaught Java exception: java.lang.NoClassDefFoundError: java/lang/xyz

A `NoClassDefFoundError` can have one of several possible reasons.

### The class does not exist.

- Check the class name for spelling errors.
- If it is an inner class, the last separator in the fully qualified class name must be a `$` character, not a `.` (dot), e.g. `org.apache.poi.hssf.util.HSSFColor$PALE_BLUE`.
- If the class is in a jar file, open the jar file with a suitable compression program, e.g. 7-Zip.
  - Check that the jar file really contains the class file.
  - Check that the jar file is not corrupt.

### The class is not on the class path.

Verify that the class file is on the class path. If the classpath contains relative paths, verify that the current working directory is what you expect it to be.

## VisualWorks image freeze

If you are using callbacks from Java to Smalltalk, and the Java part of your application uses other native threads besides the thread which executes the Smalltalk code, you may have run into a deadlock. If your application uses Java user interface code (e.g. Swing, AWT), there may be separate threads even if you did not start them explicitly. See the description of the problems with threads for more information.
Can't load libjvm.dylib on OS X

If you run into this error, you probably configured JNIPort to use a 64 bit Java VM. However, a 64 bit library can't be used with a 32 bit VisualWorks VM. Select a 32 bit Java VM instead.
