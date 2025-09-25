Extension { #name : 'Exception' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Exception >> jniportNotify [
	JNIPortNotification signal: 'Error: ' , self description
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Exception >> parameter [
	^self tag
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Exception class >> raiseSignal: aString [
	^self signal: aString
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Exception class >> signal: aString with: anObject [ 
	^ self new
		tag: anObject;
		signal: aString
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Exception >> toTrace [
	Transcript show: self description; cr
]
