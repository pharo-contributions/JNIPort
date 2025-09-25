Extension { #name : 'Behavior' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Behavior >> allSubclassesPreOrderDo: aBlock [ 
	"Dolphin Smalltalk compatibility"

	^self allSubclassesDo: aBlock
]
