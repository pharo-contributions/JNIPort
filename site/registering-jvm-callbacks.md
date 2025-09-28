# Registering callbacks for the Java VM hooks

The JVM class in JNIPort registers callbacks for the Java VM events when it is configured to do so via the JNIPortSettings. The JNIPortSettings has three boolean properties indicating whether to create a callback or not. When their values are true, the JVM instance will trigger events when the Java VM calls the respective callbacks.

| Event | JNIPortSettings property | JVM event name | Parameters |
| ----- | ------------------------ | -------------- | ---------- |
| Text message | useVFPrintfHook | #JVMMessage:address: | a String, a CPointer (FILE *) |
| Abort notification | useAbortHook | #JVMAbort | no parameters |
| Exit notification | useExitHook | #JVMExit: | Integer return code of the Java VM  |

By default, there are no handlers for the events, such that nothing really happens. You have to register event handlers to do something useful.

Here is an example:

```smalltalk
| settings jvm |
settings := JVMSettings new. settings usesGhosts: true.
(settings jniPortSettings)
  jvmClass: JVMWithoutCallbacks;
  jniLibraryFilename: 'C:\Programs\Java\jre1.6.0_01\bin\client\jvm.dll';
  "Let the JVM register callbacks for the Java VM hooks."
  useVFPrintfHook: true;
  useAbortHook: true;
  useExitHook: true.
"Let the Java VM send a message whenever it loads a class."
setting runtimeSettings addOption: '-verbose:class'.
jvm := JVM newWithSettings: settings.
jvm
  when: #JVMMessage:address: evaluate: [:string :address | Transcript nextPutAll: string];
  when: #JVMAbort evaluate: [Transcript show: 'JVM abort() -- closing down'; cr];
  when: #JVMExit: evaluate: [:returnCode | Transcript show: 'JVM exit() -- closing down - '; print: returnCode; cr]  
```

Of course, logging abort and exit notifications to the Transcript is not really helpful, as the Java VM will quit immediately after. This will stop the process including the Smalltalk VM, such that you won't see the output any more. There are two useful ways to use use the abort and exit hooks:

- In a runtime environment, you can release external resources which should be released before the program quits. E.g., you can close database connections or open sockets.

- In a development environment, you can put a "nil halt" in the callback to intercept the shutdown process for debugging purposes.

