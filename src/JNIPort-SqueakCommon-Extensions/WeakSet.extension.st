Extension { #name : 'WeakSet' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
WeakSet >> findElement: anObject ifAbsent: aBlock [
	"Dolphin Smalltalk compatibility: Searches for an element equal to anObject. Answers the element found. If not found, answers the result of evaluating aZeroArgumentBlock"

	| index element |
	index := self findElementOrNil: anObject.
	element := array at: index.
	^(element isNil or: [element == flag]) ifTrue: [aBlock value] ifFalse: [element].
]
