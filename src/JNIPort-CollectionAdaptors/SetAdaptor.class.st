"
Adaptor to make any subject which understands <#add:, #do: #remove:ifAbsent: #size #includes> function as a Set.

"
Class {
	#name : 'SetAdaptor',
	#superclass : 'Collection',
	#type : 'variable',
	#instVars : [
		'subject'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
SetAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #add:, #do: #remove:ifAbsent:
	#includes, and #size to that object.  If the subject understands #rehash and #shrink then they
	are also forwarded"

	^ (self basicNew: 1)		"using a capacity of 1 may help avoid divide-by-zero errors"
		subject: anObject;
		yourself.
]

{ #category : 'adding' }
SetAdaptor >> add: anObject [
	"one of the root methods for <Collection>"

	^ subject add: anObject.
]

{ #category : 'copying' }
SetAdaptor >> copyEmpty: anInteger [
	"private -overriden to use species (which it probably should have done in the first place)"

	^ self species new: anInteger.
]

{ #category : 'enumerating' }
SetAdaptor >> do: a1Block [
	"one of the root methods for <Collection>"

	^ subject do: a1Block.
]

{ #category : 'testing' }
SetAdaptor >> includes: anObject [
	"one of the root methods for <Set>"

	^ subject includes: anObject.
]

{ #category : 'removing' }
SetAdaptor >> remove: anObject ifAbsent: a0Block [
	"one of the root methods for <Collection>"

	^ subject remove: anObject ifAbsent: a0Block.
]

{ #category : 'accessing' }
SetAdaptor >> size [
	"one of the root methods for <Collection>"

	^ subject size.
]

{ #category : 'private' }
SetAdaptor >> species [
	"answer the kind of collection to be used when copying the receiver"

	^ Set.
]

{ #category : 'accessing' }
SetAdaptor >> subject [
	"private -- answer the receiver's subject"

	^ subject.
]

{ #category : 'initializing' }
SetAdaptor >> subject: anObject [
	"private -- set the receiver's subject to anObject"

	subject := anObject.
]
