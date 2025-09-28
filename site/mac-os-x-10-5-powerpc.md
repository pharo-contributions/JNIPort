# Instructions for Mac OS X 10.5 PowerPC

It seems that the Java VM of the Mac OS X JDK on PowerPC tries to call back into the host program using an API which is not supported by the VisualWorks VM (VisualWorks 7.6 and later). If you want to use JNIPort on this platform, try using another JVM implementation.

JamVM with the Gnu Classpath libraries is known to work with JNIPort on PowerPC. However, in JNIPort 1.8 and earlier, you have to change the method JNIInterface class>>#concreteClassForCurrentPlatform such that it selects the class JNIInterface instead of JNIInterfaceForMacOSX as the external interface to the Java VM. The reason is that some JNI functions of the Mac OS X JDK have names which are different from the names defined by the JNI specification. Their names have a suffix "_Impl". JNIInterfaceForMacOSX calls those functions instead of the functions defined in the JNI specification. JamVM (and probably all other Java VM implementations) uses the standard names. Therefore, one has to use the class JNIInterface instead of JNIInterfaceForMacOSX.

A future version of JNIPort may be more intelligent about choosing the appropriate subclass of ExternalInterface, but currently, you have to modify the method named above.

Some more hints for Gnu Classpath:

When you compile GNU classpath from source and receive a significant amount of errors within Java, and the compile terminates, you probably compiled the class libraries with javac version 1.5. You have to compile Gnu Classpath with ecj, see http://developer.classpath.org/pipermail/classpath/2008-March/002500.html. It may still show a lot of warnings.

Basic steps:

- download ecj, e.g. ecj-3.4.1.jar
- create a shell script /usr/local/ecj

```sh
#!/bin/sh
CLASSPATH=/usr/local/share/java/ecj.jar${CLASSPATH:+:}$CLASSPATH \
  java -Xms256M -Xmx512M org.eclipse.jdt.internal.compiler.batch.Main "$@"
```
Configure classpath

```
./configure --disable-gtk-peer --disable-gconf-peer --disable-plugin
```

Make and install

```
make; make install
```

_Thanks to Holger Kleinsorgen for providing this information and testing JNIPort with Mac OS X PPC!_