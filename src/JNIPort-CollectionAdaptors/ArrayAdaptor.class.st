"
Adaptor to make any subject which understands <#size, #at: #at:put:> and (optionally) #from:to:keysAndValuesDo:, function as a SequenceableCollection.

"
Class {
	#name : 'ArrayAdaptor',
	#superclass : 'ArrayedCollection',
	#instVars : [
		'subject',
		'diyLoop'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
ArrayAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #size, #at: and #at:put:
	to that object;  if the subject also understands #from:to:keysAndValuesDo: or, #replaceFrom:to:with:startingAt:
	then that's gravy and we'll forward them too"

	^ (self basicNew)
		subject: anObject;
		yourself.
]

{ #category : 'accessing' }
ArrayAdaptor >> at: anInteger [
	"one of the root methods for <SequenceableCollection>"

	^ subject at: anInteger.
]

{ #category : 'accessing' }
ArrayAdaptor >> at: anInteger put: anObject [
	"one of the root methods for <SequenceableCollection>"

	^ subject at: anInteger put: anObject.
]

{ #category : 'copying' }
ArrayAdaptor >> copyEmpty: anInteger [
	"private -overriden to use species (which it probably should have done in the first place)"

	^ self species new: anInteger.
]

{ #category : 'enumerating' }
ArrayAdaptor >> from: aStartIndex to: aStopIndex keysAndValuesDo: a2Block [ 
	^diyLoop 
		ifTrue: 
			[super 
				from: aStartIndex
				to: aStopIndex
				keysAndValuesDo: a2Block]
		ifFalse: 
			[subject 
				from: aStartIndex
				to: aStopIndex
				keysAndValuesDo: a2Block]
]

{ #category : 'enumerating' }
ArrayAdaptor >> select: aBlock [ 
	"Optimized version of Collection>>#select:"
	
	^ self species new: self size streamContents: [ :stream|
		1 to: self size do: [ :index |
			| each |
			(aBlock value: (each := self at: index))
				ifTrue: [ stream nextPut: each ]]]
]

{ #category : 'accessing' }
ArrayAdaptor >> size [
	"one of the root methods for <Collection>"

	^ subject size.
]

{ #category : 'private' }
ArrayAdaptor >> species [
	"answer the kind of collection to be used when copying the receiver"

	^Array
]

{ #category : 'accessing' }
ArrayAdaptor >> subject [
	"private -- answer the receiver's subject"

	^ subject.
]

{ #category : 'initializing' }
ArrayAdaptor >> subject: anObject [ 
	"private -- set the receiver's subject to anObject"

	subject := anObject.
	diyLoop := (anObject respondsTo: #from:to:keysAndValuesDo:) not
]
