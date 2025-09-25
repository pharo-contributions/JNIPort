"
JNIPortWeakRegistry is a subclass of WeakRegistry which serves as an alias for that class, such that JNIPort can use the same class name in all Smalltalk dialects.
"
Class {
	#name : 'JNIPortWeakRegistry',
	#superclass : 'WeakRegistry',
	#category : 'JNIPort-SqueakCommon-Extensions-Imported',
	#package : 'JNIPort-SqueakCommon-Extensions',
	#tag : 'Imported'
}

{ #category : 'accessing' }
JNIPortWeakRegistry >> registerValueOf: aBlock [
	"Register the object that is the result of evaluating aBlock.
	Don't register if the response is nil.

	Answer the result of evaluating aBlock."

	| object |
	object := aBlock value.
	object == nil ifFalse: [ self add: object ].
	^ object
]
