"
JNIPortUtility is a class holding some utility methods which need different implementations in different Smalltalk dialects.

"
Class {
	#name : 'JNIPortUtility',
	#superclass : 'Object',
	#category : 'JNIPort-SqueakCommon-Extensions-Imported',
	#package : 'JNIPort-SqueakCommon-Extensions',
	#tag : 'Imported'
}

{ #category : 'utilities' }
JNIPortUtility class >> exceptionsWithoutNotifications [
	"Answer an ExceptionSet which matches all Exceptions, but not Notifications and similar signals which can be ignored"

	^Exception - Notification
]

{ #category : 'utilities' }
JNIPortUtility class >> executesForeignCallbacksInSmalltalkThread [
	"Answer if the Smalltalk VM executes a callback from a thread other than the one executing Smalltalk code in the Smalltalk thread. This is false for Pharo and Squeak."

	^false
]

{ #category : 'utilities' }
JNIPortUtility class >> flushVMmethodCache [
	"Flushing the VM method cache can be necessary after discarding lots of classes in some Smalltalk environments. In Pharo/Squeak, this is not necessary, so this method does nothing."
	
	Object flushCache
]

{ #category : 'utilities' }
JNIPortUtility class >> garbageCollect [
	Smalltalk garbageCollect
]

{ #category : 'utilities' }
JNIPortUtility class >> isRuntime [
	^false
]

{ #category : 'utilities' }
JNIPortUtility class >> signalEndOfStream: aStream [
	"Some Smalltalk dialects raise a Notification when the end of a Stream is reached, some just return nil. Squeak and Pharo return nil."

	^nil
]

{ #category : 'utilities' }
JNIPortUtility class >> subscriptOutOfBoundsError [

	^SubscriptOutOfBounds
]

{ #category : 'utilities' }
JNIPortUtility class >> supportsForeignCallbacksFromJava [

	^false
]

{ #category : 'utilities' }
JNIPortUtility class >> waitForMilliseconds: anInteger [

	(Delay forMilliseconds: anInteger) wait
]
