Extension { #name : 'Object' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> becomeA: aClass [

	| newInstance |
	newInstance := aClass newInstanceFrom: self 
		variable: aClass isVariable 
		size: aClass instSize 
		map: (aClass instVarMappingFrom: self class).
	^self become: newInstance
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> errorNotFound: anObject [ 
	"Raise aError indicating that anObject was not found."

	^Error signal: 'Element not found' with: anObject
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> jniAssert: aBlock [ 
	"Renamed from assert: to avoid conflicts with SUnit and other implemetations of assert:."

	aBlock value ifFalse: [JNIPortAssertionFailure signal]
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> removeAllActionsWithReceiver: aJNIPortCallbackEventsTest [
	"VisualWorks compatibility"

	^ self removeActionsWithReceiver: aJNIPortCallbackEventsTest
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> swappingBecome: anObject [ 
	"Dolphin Smalltalk Compatibility"

	^self become: anObject
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> trigger: aSymbol [ 
	"Dolphin Smalltalk compatibility"

	^self triggerEvent: aSymbol
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> trigger: aSymbol with: anArgument [ 
	"Dolphin Smalltalk compatibility"

	^self triggerEvent: aSymbol with: anArgument
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> trigger: aSymbol with: anArgument1 with: anArgument2 [
	"Dolphin Smalltalk compatibility"

	^ self triggerEvent: aSymbol withArguments: (Array with: anArgument1 with: anArgument2)
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Object >> trigger: aSymbol withArguments: anArray [ 
	"Dolphin Smalltalk compatibility"

	^self triggerEvent: aSymbol withArguments: anArray
]
