Class {
	#name : 'JNIPortNotification',
	#superclass : 'Notification',
	#category : 'JNIPort-SqueakCommon-Extensions-Imported',
	#package : 'JNIPort-SqueakCommon-Extensions',
	#tag : 'Imported'
}

{ #category : 'exceptiondescription' }
JNIPortNotification >> defaultAction [
	self toTrace.
	^super defaultAction
]
