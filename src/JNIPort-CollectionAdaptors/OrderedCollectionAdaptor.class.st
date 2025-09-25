"
Adaptor to make any subject which understands <#size, #at: #at:put: #add: #removeAtIndex:> and (optionally) <#from:to:keysAndValuesDo: #removeAll #replaceFrom:to:with:startingAt:>, function as a SequencedGrowableCollection.

So far, only a few methods are implemented, which are not enough to be compatible with OrderedCollection. Additional methods should be added as needed.

"
Class {
	#name : 'OrderedCollectionAdaptor',
	#superclass : 'SequenceableCollection',
	#type : 'variable',
	#instVars : [
		'subject',
		'diyLoop',
		'diyReplace'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
OrderedCollectionAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #size, #at: #at:put: #add:afterIndex:
	and #removeAtIndex: to that object;  if the subject also understands #from:to:keysAndValuesDo:,
	#removeAll, or #replaceFrom:to:with:startingAt: then that's gravy and we'll forward them too"

	^ (self basicNew)
		subject: anObject;
		yourself.
]

{ #category : 'adding' }
OrderedCollectionAdaptor >> add: anObject [
	^subject add: anObject
]

{ #category : 'adding' }
OrderedCollectionAdaptor >> add: anObject afterIndex: anIndex [
	"one of the root methods for <SequencedGrowableCollection>"

	^ subject add: anObject afterIndex: anIndex.
]

{ #category : 'accessing' }
OrderedCollectionAdaptor >> at: anIndex [
	"one of the root methods for <SequenceableCollection>"

	^ subject at: anIndex.
]

{ #category : 'accessing' }
OrderedCollectionAdaptor >> at: anIndex put: anObject [
	"one of the root methods for <SequenceableCollection>"

	^ subject at: anIndex put: anObject.
]

{ #category : 'mutating' }
OrderedCollectionAdaptor >> changeCapacityTo: anInteger [
	"private -- overridden to ignore"
]

{ #category : 'copying' }
OrderedCollectionAdaptor >> copyEmpty: anInteger [
	"private -overriden to use species (which it probably should have done in the first place)"

	^ self species new: anInteger.
]

{ #category : 'enumerating' }
OrderedCollectionAdaptor >> from: aStartIndex to: aStopIndex keysAndValuesDo: a2Block [
	"one of the root methods for <SequenceableCollection>, optional because it can be
	implemented in terms of #at: and #size"

	"if the subject doesn't understand this, then we inline the loop here for speed rather then
	falling back to the superclass implementation"
	^ diyLoop
		ifTrue: [aStartIndex to: aStopIndex do: [:i | a2Block value: i value: (subject at: i)]]
		ifFalse: [subject from: aStartIndex to: aStopIndex keysAndValuesDo: a2Block].
]

{ #category : 'private' }
OrderedCollectionAdaptor >> insert: anObject before: spot [ 
	^self add: anObject afterIndex: spot - 1
]

{ #category : 'removing' }
OrderedCollectionAdaptor >> removeAtIndex: anIndex [
	"one of the root methods for <SequencedGrowableCollection>"

	^ subject removeAtIndex: anIndex.
]

{ #category : 'accessing' }
OrderedCollectionAdaptor >> replaceFrom: aStartIndex to: aStopIndex with: replacementElements startingAt: aReplacementIndex [
	"one of the root methods for <SequenceableCollection>, optional because it can be
	implemented in terms of #at:, #at:put:, and #size"

	^ diyReplace
		ifTrue: [super replaceFrom: aStartIndex to: aStopIndex with: replacementElements startingAt: aReplacementIndex]
		ifFalse: [subject replaceFrom: aStartIndex to: aStopIndex with: replacementElements startingAt: aReplacementIndex].
]

{ #category : 'accessing' }
OrderedCollectionAdaptor >> size [
	"one of the root methods for <Collection>"

	^ subject size.
]

{ #category : 'private' }
OrderedCollectionAdaptor >> species [
	"answer the kind of collection to be used when copying the receiver"

	^ OrderedCollection.
]

{ #category : 'accessing' }
OrderedCollectionAdaptor >> subject [
	"private -- answer the receiver's subject"

	^ subject.
]

{ #category : 'initializing' }
OrderedCollectionAdaptor >> subject: anObject [
	"private -- set the receiver's subject to anObject"

	subject := anObject.

	diyLoop := (anObject respondsTo: #from:to:keysAndValuesDo:) not.
	diyReplace := (anObject respondsTo: #replaceFrom:to:with:startingAt:) not.
]
