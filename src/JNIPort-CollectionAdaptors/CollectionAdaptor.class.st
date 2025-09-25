"
Adaptor to make any subject which understands <#add:, #do: #remove:ifAbsent: #size> and (optionally) #includes: function as a Collection.

"
Class {
	#name : 'CollectionAdaptor',
	#superclass : 'Collection',
	#instVars : [
		'subject',
		'diyIncludes'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
CollectionAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #add:, #do: #remove:ifAbsent:
	and #size to that object.  If the subject doesn't understand #species or responds to it with its
	own class (which can't be suitable for our purposes or it wouldn't be wrapped in one of these)
	then we'll ask for it's species when copying.  If the subject also understands #includes: then
	that's gravy and we'll forward it too"

	^ (self basicNew: 1)		"using a non-zero basic size may help avoid divide-by-zero errors"
		subject: anObject;
		yourself.
]

{ #category : 'adding' }
CollectionAdaptor >> add: anObject [
	"one of the root methods for <Collection>"

	^ subject add: anObject.
]

{ #category : 'copying' }
CollectionAdaptor >> copyEmpty: anInteger [
	"private -overriden to use species (which it probably should have done in the first place)"

	^ self species new: anInteger.
]

{ #category : 'enumerating' }
CollectionAdaptor >> do: a1Block [
	"one of the root methods for <Collection>"

	^ subject do: a1Block.
]

{ #category : 'testing' }
CollectionAdaptor >> includes: anObject [
	"one of the root methods of Collection; optional because it can be implemented
	in terms of #do:"

	^ diyIncludes
		ifTrue: [super includes: anObject]
		ifFalse: [subject includes: anObject].
]

{ #category : 'removing' }
CollectionAdaptor >> remove: anObject ifAbsent: a0Block [
	"one of the root methods for <Collection>"

	^ subject remove: anObject ifAbsent: a0Block.
]

{ #category : 'accessing' }
CollectionAdaptor >> size [
	"one of the root methods for <Collection>"

	^ subject size.
]

{ #category : 'private' }
CollectionAdaptor >> species [
	"answer the kind of collection to be used when copying the receiver"

	"it is arguable that the fundamental concrete container is actually Bag, however
	it seems a little perverse, so I've choosen to use"
	^ OrderedCollection.
]

{ #category : 'accessing' }
CollectionAdaptor >> subject [
	"private -- answer the receiver's subject"

	^ subject.
]

{ #category : 'initializing' }
CollectionAdaptor >> subject: anObject [
	"private -- set the receiver's subject to anObject"

	subject := anObject.
	diyIncludes := (subject respondsTo: #includes) not.
]
