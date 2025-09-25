Extension { #name : 'Set' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Set >> findElement: anObject ifAbsent: aBlock [
	"Dolphin Smalltalk compatibility: Searches for an element equal to anObject. Answers the element found. If not found, answers the result of evaluating aZeroArgumentBlock"

	| index element |
	index := self findElementOrNil: anObject.
	element := array at: index.
	^element isNil ifTrue: [aBlock value] ifFalse: [element].
]
