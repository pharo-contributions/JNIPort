Extension { #name : 'Integer' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Integer >> asDouble [
	^self asFloat
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Integer >> mask: anInteger set: aBoolean [ 
	"Treat the argument as a bit mask.  Answer a copy of the receiver with the
	corresponding bits turned on if aBoolean is true, or turned off if aBoolean is false.
	Dolphin Smalltalk compatibility"

	^aBoolean 
		ifTrue: [self bitOr: anInteger]
		ifFalse: [self bitClear: anInteger]
]
