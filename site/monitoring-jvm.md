# Monitoring messages from the Java Virtual Machine

The Java Native Interface provides hooks where an application can register callback functions for three kinds of events:

- The Java VM sends a message.
- The Java VM is about to abort.
- The Java VM is about to exit.

These callbacks are registered with the Java VM, not with individual Java objects. These two types of callbacks are not related and can be used independently.

Which text messages the Java VM produces is controlled by VM options. In JNIPort, these options are configured in the [JavaRuntimeSettings](javaruntimesettings.md) before starting the JVM. For example, if you want to monitor which classes the Java VM loads from which files, you would use the option '-verbose:class'.

[Registering callbacks for the Java VM hooks](registering-jvm-callbacks.md)

[The JNIHelper DLL](jnihelper.md)

[The Problems with Threads](problems-with-threads.md)