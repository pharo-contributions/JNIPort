"
Adaptor to make any subject which understands <#at:ifAbsent #at:put: #keysAndValuesDo: #removeKey:ifAbsent: #size> and, optionaly <#includesKey:> function as a Dictionary.

"
Class {
	#name : 'DictionaryAdaptor',
	#superclass : 'Dictionary',
	#type : 'variable',
	#instVars : [
		'subject',
		'diyIncludes'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
DictionaryAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #at:ifAbsent, #at:put:, #keysAndValuesDo:,
	#removeKey:ifAbsent:, and #size to that object.  If the subject understands #includesKey:, #rehash, or
	#shrink then they are also forwarded"

	^ (self basicNew: 1)		"using a capacity of 1 may help avoid divide-by-zero errors"
		subject: anObject;
		yourself.
]

{ #category : 'adding' }
DictionaryAdaptor >> add: anAssociation [ 
	"one of the root methods for <Collection>.  Overriden to 'know' about bloody Associations"

	^self at: anAssociation key put: anAssociation value
]

{ #category : 'accessing' }
DictionaryAdaptor >> associationAt: aKey ifAbsent: a0Block [ 
	"this association crap is the absolute limit"

	| val |
	val := self at: aKey ifAbsent: [^a0Block value].
	^aKey -> val
]

{ #category : 'dictionary enumerating' }
DictionaryAdaptor >> associationsDo: a1Block [ 
	^self keysAndValuesDo: [:key :value | a1Block value: key -> value]
]

{ #category : 'accessing' }
DictionaryAdaptor >> at: aKey ifAbsent: a0Block [
	"one of the root methods for <Dictionary>"

	^ subject at: aKey ifAbsent: a0Block.
]

{ #category : 'accessing' }
DictionaryAdaptor >> at: aKey put: anObject [
	"one of the root methods for <Dictionary>"

	^ subject at: aKey put: anObject.
]

{ #category : 'private' }
DictionaryAdaptor >> changeCapacityTo: anInteger [

	"overridden to ignore"
]

{ #category : 'copying' }
DictionaryAdaptor >> copyEmpty: anInteger [
	"private -overriden to use species (which it probably should have done in the first place)"

	^ self species new: anInteger.
]

{ #category : 'enumerating' }
DictionaryAdaptor >> do: a1Block [ 
	^self keysAndValuesDo: [:key :value | a1Block value: value]
]

{ #category : 'dictionary testing' }
DictionaryAdaptor >> includesKey: aKey [
	"one of the root methods for <Dictionary>, optional because implementable in terms
	of at:ifAbsent:"

	^ diyIncludes
		ifTrue: [subject at: aKey ifAbsent: [^ false]. true]
		ifFalse: [subject includesKey: aKey].
]

{ #category : 'enumerating' }
DictionaryAdaptor >> keysAndValuesDo: a2Block [
	"one of the root methods for <Dictionary>"

	^ subject keysAndValuesDo: a2Block.
]

{ #category : 'dictionary removing' }
DictionaryAdaptor >> removeKey: aKey ifAbsent: a0Block [
	"one of the root methods for <Dictionary>"

	^ subject removeKey: aKey ifAbsent: a0Block.
]

{ #category : 'accessing' }
DictionaryAdaptor >> size [
	"one of the root methods for <Collection>"

	^ subject size.
]

{ #category : 'private' }
DictionaryAdaptor >> species [
	"answer the kind of collection to be used when copying the receiver"

	^Dictionary
]

{ #category : 'accessing' }
DictionaryAdaptor >> subject [
	"private -- answer the receiver's subject"

	^ subject.
]

{ #category : 'initializing' }
DictionaryAdaptor >> subject: anObject [
	"private -- set the receiver's subject to anObject"

	subject := anObject.

	diyIncludes := (anObject respondsTo: #includesKey:) not.
]
