# The JNIHelper DLL

JNIHelper is a C DLL, plus the Smalltalk code to use it. It exists only because of the mismatch between the Smalltalk and Java VM models of threads.

Currently, the JNIHelper is available for 32-bit MS Windows only. If you want to use it on other platforms, you have to adapt it to this platform yourself. If possible, please publish your work and make it available, preferably under the MIT license.

The Java VM has three callback “hooks”; these are callback functions that JNI clients can replace with their own functions. The hook functions are called:

- When the JVM is about to exit.
- When the JVM is about to abort (i.e. an abnormal exit).
- When the JVM has some debugging information to display (this would otherwise be written to the console, but is not the same as the Java standard output streams).

Dolphin's and VisualWorks' external interfacing is (with some extensions to handle `varargs` functions) capable of using these hook functions. Unfortunately, because the Java VM uses OS-level threads (at least the Sun JVM does), which Dolphin and VisualWorks can't handle directly, this is prone to deadlock. See the [problem with threads](problems-with-threads.md) for the details.

The JNIHelper library provides a way around this. It provides replacements for the JNI hooks that can be called from any thread. The way it works is (slightly simplified) that when the replacement hook function is called, it stores the data provided with the call on an internal queue, and then returns immediately to the caller. A separate thread waits for data to appear on the queue, and when it does, it calls back into Smalltalk to allow JNIPort to consume the data. Since the caller never waits for Smalltalk, this should avoid the risk of deadlock.

An additional feature of JNI Helper is to allow the JVM's debugging stream to be redirected to the Window's system debug stream, where it can be viewed with a tool like DebugView from Microsoft's Sysinternals Suite. This should completely eliminate any possibility of the debugging output causing deadlocks.

It is possible to use JNIPort without the JNIHelper. You can either just not use the hooks at all (set from the [configuration](jniportsettings.md)) which will side-step the problem entirely, or you can accept a risk of deadlock. Unless you are using more than one Java thread then you will probably get away with it. (But note that some Java features use threads even if you haven't explicitly started any — AWT/Swing for one.)

The DolphinJNIHelper DLL, and the C source and a VC++ project file, are in the Extras\ folder which is part of the JNIPort download. Put the DLL somewhere where Dolphin or VisualWorks can find it.

Please note: It is recommended that you rebuild the DLL from source if you can, or, at minimum, run it through a reputable, and up to date, virus checker.