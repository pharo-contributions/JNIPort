# The Problems with Threads

This section is about the problems caused by the mismatch between the ways that the Java runtime and Smalltalk use and understand operating system threads.

The discussion may be quite off-putting, since it describes various ways of getting into trouble without expecting to. Of course, you can do that with any threaded code, but the Java/Smalltalk mix is particularly hard to get right. There's nothing much more that can be done to help with that; while this section is as comprehensible as possible, it's still not an easy read. We offer the following guideline:

A Guideline:

Mixing Java threads with Smalltalk Processes is risky or difficult. Try to ensure that at any time **either** Java is quiescent, waiting to be invoked from any Smalltalk Processes, but not itself running any active threads, **or** Smalltalk is quiescent, waiting to be invoked by callbacks from any Java threads, but not doing any other work in background Processes.

## Overview

The Java runtime from Oracle implements Java threads as Windows threads. Other JVMs for Windows either do the same, or multiplex several Java threads onto each OS thread (at least older versions of the IBM and BEA runtimes seem do this, or can be configured to do so). In either case the Java runtime is thread-intensive and is thread-aware.

Dolphin, VisualWorks, Squeak, and Pharo on the other hand, execute all Smalltalk code in just one OS thread. All the Smalltalk Processes are executed by that thread. Dolphin and VisualWorks do make some use of other OS threads, and are also thread-aware.

With a good deal of messing around, some determined turning of blind eyes to theoretical problems, and quite a bit of care, it is possible to reconcile these two systems.

Almost all of the problems revolve around callbacks from the Java runtime into Smalltalk. (The other problems are described below.) The Java runtime calls Smalltalk code in two ways: when a Java “native method” is implemented by Smalltalk code, and when the Java runtime's “hook” functions are implemented by external callbacks. Later sub-sections go into more details, but the problem, and the general strategy for avoiding it, are the same in both cases.

## The General Problem

_The following discussion currently applies only to Dolphin and VisualWorks. Pharo (as of fall 2014) does not support callbacks into Smalltalk from foreign threads._

The problem is that the callback into Smalltalk can be made from an OS thread that is not the one that Smalltalk uses for running Smalltalk code (call it the Smalltalk thread). In an ideal world Smalltalk would be able to execute Smalltalk code on any OS thread, in which case these issues would vanish, but this is not an ideal world. Fortunately, Dolphin and VisualWorks have a basic ability to handle such calls. When Dolphin or VisualWorks find that one of their ExternalCallbacks is being invoked from a thread that is not the Smalltalk thread, it blocks the caller, and passes the call to the Smalltalk thread for execution, then passes back the answer (if any) back to the blocked thread, which is then allowed to proceed.

One detail is worth noting for Dolphin: the external callback will be executed by the Dolphin “main” Process (the one that runs the Windows event dispatch loop).

Unfortunately that can lead to deadlocks. One way is because Smalltalk cannot service callbacks while the Smalltalk thread is executing Java code:

The threads are now deadlocked; each waiting for the other.

Another way to create a deadlock is if the a background thread takes out a lock, and then invokes an ExternalCallback which indirectly results in the Smalltalk thread trying to acquire the same lock. For instance:

The threads are deadlocked.

In Dolphin, a related, but not identical, source of deadlocks is:

| The Smalltalk Thread  | Another Thread |
| --------------------- | -------------- |
| Executes Smalltalk code that, in turn, calls something in the Java runtime. | |
| Which starts a new thread, or alerts an existing thread, and waits for it to complete some action. | |
| …waiting… | Attempts to invoke a Smalltalk callback. |
| …waiting… | Is blocked by Smalltalk waiting for the callback to be handled by the Smalltalk thread. |
| …waiting… | …waiting…  |


| A Background Thread | The Smalltalk Thread |
| ------------------- | -------------------- |
| Acquires a lock on some object, lock.	 | |
| Issues an external callback into Smalltalk. | |	
| Is blocked by Smalltalk waiting for the callback to be handled by the Smalltalk thread. | |
| …waiting… | Sees the external callback waiting, finds the handler for that callback and executes it. |
| …waiting… | The handler calls a Java method that is synchronised on the original lock object. |
| …waiting… | It is blocked by the Java runtime, waiting for that lock to be released by the background thread. |
| …waiting… |…waiting… |


| A Background Thread | The Smalltalk Thread |
| ------------------- | -------------------- |
| Acquires a lock on some object, lock. | |	
| Issues an external callback into Smalltalk. |
| Is blocked by Smalltalk waiting for the callback to be handled by the Smalltalk thread. |
| …waiting… | Before the callback is handled, Dolphin's internal scheduler wakes up some other Process; possibly it is a background process, but remember that they all run on the same OS thread. |
| …waiting… | That Process calls a Java method that is synchronised on the original lock object. |
| …waiting… | It is blocked by the Java runtime, waiting for that lock to be released by the background thread. |
| …waiting… | …waiting…  |

### The General "Solution"

The technique that JNIPort uses for dealing with these case is to decouple the two threads wherever possible. It requires a queue and an additional thread. When the background thread wants to issue a callback, it does not call into Smalltalk directly. Instead it places the request onto a queue, and then immediately returns to its caller. The additional thread, the demon thread, has been sleeping waiting for the queue to become non-empty. When it wakes up, it sees the notification, removes it from the queue and then calls back into Smalltalk. The demon thread will be blocked at this point, waiting for Smalltalk to finish handling the callback, but the original background thread has not had to wait, and so the deadlocks are avoided. Naturally, this technique can only be used when the caller is not interested in the answer to the call.

There is an additional complication. If the code in the Java runtime that issues the call was running on the Smalltalk thread (because it had been invoked from Smalltalk via JNI), then it should issue the callback directly, rather than putting it on the queue. For pure notifications (where no answer is wanted) side-stepping the queue is just avoiding a needless inefficiency. However if an answer is needed, then the caller cannot use the queue or else a different deadlock would occur, as follows:

| The Smalltalk Thread | The Queue Demon Thread |
| -------------------- | ---------------------- |
| Executes Smalltalk code that, in turn, calls some code in the Java runtime. | …sleeping… |
| The Java code issues an external callback into Smalltalk. | …sleeping… |
| It places the request on the queue, and then sleeps waiting for an answer. | 	…sleeping… |
| …waiting… | Wakes up, dequeues the request, and issues an external callback into Smalltalk. |
| …waiting… | The Smalltalk VM sees the request and blocks the sender until the main Process on the Smalltalk thread can handle it. |
| …waiting… | …waiting… |

## Hook functions

The Java runtime has three hook functions. These are pointers to functions that will be invoked by the runtime to allow client code to monitor the state of the JVM. In particular this is used for the runtime's debugging/logging output, such as the trace of loaded classes produced if the -verbose:class flag is provided. Dolphin's and VisualWorks' external callbacks are capable (with a small extension provided by JNIPort to enable varargs) of acting as the necessary hooks. The problem is that the hook functions can be (and are) invoked from any OS thread, so deadlocks are likely.

A particularly common way that the hook functions can cause deadlocks is through the Java logging/tracing feature. One example is Swing. When Swing is starting up, as the first window is displayed, Swing starts a new Java thread to handle user-interactions. So, in the first call to display a window, something like aFrame pack_null; show_null., the call to #pack_null calls Java code that starts the Swing thread and waits for it to confirm that it is running (somehow). If the new thread produced any logging (as is likely if the -verbose:class or -verbose:jni flags are turned on), then Smalltalk/Java will deadlock. This is a special case of the first form of deadlock, above.

The JNI Helper library is an external DLL that provides wrapper functions for external callbacks. The wrapper functions use the queue/demon approach internally to ensure that threads other than the Smalltalk thread are never blocked waiting for Smalltalk to handle the notification.

With the JNI Helper, as far as is currently known, all the deadlocks arising from logging are avoided.

## Native Methods, Notifications, and Requests

The other way that a Java runtime can invoke code in Smalltalk is via Java's “native methods”. A native method is a Java method that is declared but not defined in the Java code, instead an implementation is provided by external (to the JVM) code. The implementation can be provided by using JNI to set a pointer to a handler function (it can also be provided by a DLL but that is not relevant to JNIPort).

As in the case of hooks, Smalltalk's external callback feature can be used to create a "function pointer" that will actually cause Smalltalk code to be executed. But, again, there is a risk of deadlocks. JNIPort includes a Java library that uses the queue/demon approach to avoid or reduce the risk. In this case JNIPort can't eliminate the risk, since sometimes the caller does need to wait for an answer. For that reason Java callbacks are broken down into Notifications and Requests. Both go via the queue, but only the latter wait for an answer. See Callbacks for more information on how to use them.

There is an additional reason for using the queue/demon approach for Java callbacks. It is unrelated to deadlocks, but is caused by a quirk of the way that JNI works with threads.

All normal JNI operations are invoked via a pointer to a JNIEnv (which is a data structure rather like a COM object or a pointer to C++ object with a vtable, the JNI API is mostly expressed as the "methods" of these objects). Each OS-thread has its own JNIEnv, and it is not allowed to use that of any other thread. In particular, all references to Java objects are via opaque "pointers" that are only valid from one OS-thread; the references are "local" to the thread's JNIEnv. (There is a way of getting a "global" reference that is valid across threads, but that doesn't help with these problems.)

In fact, whenever the Java runtime calls a native method, it creates new JNIEnv that will be valid only for the calling thread, and only until the callback returns. (The main point of this seems to be a half-baked attempt to make managing references to Java objects from C code slightly automatic.) That doesn't affect this discussion but does cause an additional problem that is described below.

The problem is that it makes it impossible to pass references to Java objects from Java to Smalltalk! The reason is as follows. Suppose that some Smalltalk external callback had been registered with JNI as the implementation of a Java native method. When the Java method is invoked, the Java runtime will create a new JNIEnv for the thread where the caller is running, and then pass it, a reference to the object who's method was called, and references to any parameter objects, to the external callback. Dolphin will ensure that the external callback is actually executed on the Smalltalk thread. But, unfortunately, that isn't necessarily the same thread as the original caller. If it is not, then the provided JNIEnv is useless — it cannot be used from that thread. Worse, there is no way to use the references to the 'this' object and its parameters, since those references are local to the calling thread/JNIEnv. Which is limiting, to say the least…

Fortunately a slight modification to the queue/demon approach provides a way around the problem.

In JNIPort you are not encouraged to declare native methods and create your own external callbacks to implement them. Instead you use a package of Java code that implements a queue of requests and notifications, and a queue demon to look after it. There is only one native method used by JNIPort (it is actually jniport.SmalltalkNotifierThread.smalltalkNotifierMethod(); which is static, returns void and takes no parameters), it is used to tell the Dolphin that the queue of outstanding requests is not empty. This one native method is implemented by an external callback in Dolphin. That (simplifying somewhat), goes into a loop, removing requests and notifications from the queue, executing the appropriate handler code, and (for requests only) telling the request object what the answer was. The loop continues until the queue is empty. Because Dolphin is calling "down" into Java, it gets valid object references in the normal way, so the problem with passing object references from Java to Smalltalk is circumvented.

The Notifications and Requests are Java objects that hold a reference to the originator of the request, a parameter object (which, of course, may be an array), and a "tag" object that is used to identify the Smalltalk handler code. The mapping from tag object to handlers is held by the callback registry as described in Callbacks.

The details of the interaction are quite complicated, and unfortunately have some unintuitive consequences for the order of events. To start with the simplest case, here's what happens when Java code, that happens to be running on the Smalltalk thread, sends a notification to Smalltalk:

The case where an answer is required is very similar. The differences are only that the Java code creates a Request object instead of a Notification; that the callback registry records the answer from the handler in the request object; and that the Java code (presumably) reads the answer and makes some use of it.

The next case is slightly more complicated. If a notification is issued from a thread other than the Smalltalk thread, then there are three threads that are actively involved, as follows:

By the way, I'm glossing over the details of how various race conditions are avoided. They don't affect the overall design; see the code if you're interested.

The next case is more complicated again. If a request is issued from a thread other than the Smalltalk thread, then it must wait for a reply:

One thing to note is that, for Notifications and Requests sent from the Smalltalk thread, the caller does not return until all pending callbacks have been handled. So, if there are a number of background threads submitting callbacks at the same time, the original Java code may be blocked until there happens to be a pause long enough for Smalltalk to empty the queue.

Another thing to note is that this scheme does not protect against all deadlocks. Notifications should be deadlock free, but if you are using Callbacks then you should ensure that you do not hold any locks on Java objects while you are waiting for the response.

The last important point is that, as mentioned above, if the Smalltalk thread is not executing Smalltalk, then it is not available to handle callbacks. In particular code like the following can work unexpectedly:

```java
void someMethod() {
  Thread[] workers = new Thread[10];
  // create some worker threads
  for (int i = 0; i < workers.length; i++)
      workers[i] = new Thread(...whatever...);
  // start them running
  for (int i = 0; i < workers.length; i++)
      workers[i].start();
  // wait for them all to finish
  for (int i = 0; i < workers.length; i++)
      workers[i].join();
}
```

If that method is called from Smalltalk, then it will block Smalltalk until it returns, so no callbacks can be handled until it does. If any of the worker threads issue Notifications, then Dolphin will not see them until after all the threads have died. If any of them makes a callback Requests then it will deadlock — the thread will be waiting for Smalltalk to handle the callback, but the Smalltalk thread will still be blocked waiting for all the threads to complete.

## Finalization

JNIPort releases references to Java objects by finalisation. If you read the "guideline" at the beginning of this section, then you may be struck by the thought that the Smalltalk finaliser Process will run even if the rest of Smalltalk is passively handling callbacks from Java. The impression is correct, and the way that references to Java objects are cleared by finalisation does break the guideline.

The problem is really more serious than just not adhering to an informal guideline. JNI specifies that "local" JNI references must be released by the same JNIEnv as created them. What's more, it insists (a severe and pointless restriction, in my view) that they cannot be released at all if there's another JNIEnv active at the time for the running thread. That means that finalisation cannot feasibly be used to clear local references unless JNIPort as a whole can be sure that only one JNIEnv is ever used.

That condition can be met only if no Java callbacks are ever used (the hook functions don't cause a problem here). That is the reason that there are two slightly different subclasses of the Smalltalk class JVM. One of these, JVMWithoutCallbacks (a nice imaginative name) does not support callbacks at all, and therefore can make use of local references. The other, JVMWithCallbacks, does support callbacks, but is therefore forced to convert every local JNI reference to a global one as soon as it is created.

## Other problems

Lastly, there are two race conditions that probably cannot feasibly be removed. In both cases there is a very small time period during which, if the luck were against you, JNIPort would use the wrong JNIEnv for some operation.

It might be possible to remove the race conditions by adding yet more complexity, and putting Semaphore protection around every access to the JNIEnv. That would cause a considerable increase in the already large overhead involved in using JNIPort. Since so far it has not been possible to produce any scenario where the problems manifest in practice, that step has not been taken. Possibly a future version of JNIPort will have a configurable policy of some sort rather than hard-wiring the decision.

The first case applies during a callback. As the callback is processed, i.e. when the Smalltalk VM invokes the ExternalCallback, JNIPort switches to using the new JNIEnv that the Java runtime provides for use during the callback. The problem is that at the very start and end of this period, before the new JNIEnv is installed, and after it has been removed again, other Smalltalk Processes could be scheduled to run. If that happens, and the other Process uses Java, then it will try to use the wrong JNIEnv. One potential sufferer from this scenario is the finaliser.

The other case is about exception checking of JNI calls, it is applicable even if callbacks are not enabled. JNI uses a per-JNIEnv (and, therefore, thread-local) flag to say 'an exception has been thrown from Java', and all JNI calls should check the flag (all subsequent JNI calls will fail until it is cleared). Since all Smalltalk Processes run on the same OS thread, the possibility exists that one Process could see an exception that had really been thrown from code invoked via a JNI call from another Process.

| The Smalltalk Thread | The Queue Demon Thread |
| -------------------- | ---------------------- |
| Executes Smalltalk code that uses JNIPort to invoke some method in Java. | 	…sleeping… |
| The Java code creates a Notification object, filling in a reference to 'this' and an optional parameter. | 	…sleeping… |
| It places the object on the queue and then calls the special notification method directly (because it's on the Smalltalk thread). | …sleeping… |
| The Java runtime invokes the external callback. | …sleeping… |
| The external callback passes control to the callback registry. | …sleeping…  |
| The callback registry takes the first item off the queue. It looks up the registered handler for that notification's tag. It executes the handler, discarding the answer, if any. | …sleeping… |
| The callback registry tries to take the next item off the queue, but there isn't one so it returns to its caller — the external callback. | …sleeping… |
| Which returns to the Java runtime. | …sleeping… |
| Which returns to the original Java code. |	…sleeping…  |

| A Background Thread | The Queue Demon Thread | The Smalltalk Thread |
| ------------------- | ---------------------- | -------------------- |
| The Java code creates a Notification object. | …sleeping… | |
| It places it on the queue, and then carries on with whatever other activities it wishes. It takes no further interest in the notification. | …sleeping… | |
| | Wakes up because the queue is no longer empty and calls the special notification method. |   |
| | The Java runtime invokes the external callback. | |
| | This thread is now blocked by Smalltalk, waiting for the special notification to be handled by the Smalltalk thread. | |
| | …waiting… | The Smalltalk thread sees that an external callback is waiting to be executed, and executes it. | |
| | …waiting… | The callback registry loops as above; it empties the queue of notifications, handling each one, and returns when the queue is empty. | |
| | This thread is now unblocked by the Smalltalk VM, and returns to its caller, the demon. | |
| | The demon then it goes back to sleep waiting for something to appear on the queue. | |
	