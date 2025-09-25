"
PluggableThreadSafeWeakSets are WeakSets which allow the redefinition of hashing and equality by clients, and which use a Mutex to synchronize concurrent access to the set. For example, methods which first compute an index in the hash table and then store an object at this position in the hash table must not be interrupted between these two actions by another method which alters the set.

Instance Variables
	hashBlock	<BlockContext>	A one argument block used for hashing the elements.
	equalBlock	<BlockContext>	A two argument block used for comparing the elements.

"
Class {
	#name : 'PluggableThreadSafeWeakSet',
	#superclass : 'WeakSet',
	#instVars : [
		'hashBlock',
		'equalBlock',
		'accessLock'
	],
	#category : 'JNIPort-SqueakCommon-Extensions-Imported',
	#package : 'JNIPort-SqueakCommon-Extensions',
	#tag : 'Imported'
}

{ #category : 'public' }
PluggableThreadSafeWeakSet >> add: anObject [
	^self protected: [super add: anObject]
]

{ #category : 'copying' }
PluggableThreadSafeWeakSet >> copy [
	^ (super copy)
		initializeAccessLock;
		yourself
]

{ #category : 'copying' }
PluggableThreadSafeWeakSet >> copyEmpty [

	^(super copyEmpty)
		hashBlock: self hashBlock;
		equalBlock: self equalBlock;
		yourself
]

{ #category : 'public' }
PluggableThreadSafeWeakSet >> do: aBlock after: anElement [
	^self protected: [super do: aBlock after: anElement]
]

{ #category : 'accessing' }
PluggableThreadSafeWeakSet >> equalBlock [

	^equalBlock ifNil: [[:object1 :object2 | object1 = object2]]
]

{ #category : 'accessing' }
PluggableThreadSafeWeakSet >> equalBlock: anObject [
	equalBlock := anObject
]

{ #category : 'accessing' }
PluggableThreadSafeWeakSet >> findElement: anObject ifAbsent: aBlock [
	^self protected: [super findElement: anObject ifAbsent: aBlock]
]

{ #category : 'accessing' }
PluggableThreadSafeWeakSet >> hashBlock [

	^hashBlock ifNil: [[:object | object hash]]
]

{ #category : 'accessing' }
PluggableThreadSafeWeakSet >> hashBlock: anObject [
	hashBlock := anObject
]

{ #category : 'public' }
PluggableThreadSafeWeakSet >> includes: anObject [
	^self protected: [super includes: anObject]
]

{ #category : 'private' }
PluggableThreadSafeWeakSet >> initialize: n [
	"Initialize array to an array size of n"

	super initialize: n.
	self initializeAccessLock
]

{ #category : 'private' }
PluggableThreadSafeWeakSet >> initializeAccessLock [
	accessLock := Mutex new
]

{ #category : 'accessing' }
PluggableThreadSafeWeakSet >> like: anObject [
	^self protected: [super like: anObject]
]

{ #category : 'private' }
PluggableThreadSafeWeakSet >> protected: aBlock [
	"Execute aBlock protected by the accessLock"

	^ accessLock isNil
		ifTrue: [ aBlock value ]
		ifFalse: [ accessLock critical: aBlock ]
]

{ #category : 'private' }
PluggableThreadSafeWeakSet >> rehash [
	self protected: [super rehash]
]

{ #category : 'public' }
PluggableThreadSafeWeakSet >> remove: oldObject ifAbsent: aBlock [
	^self protected: [super remove: oldObject ifAbsent: aBlock]
]

{ #category : 'private' }
PluggableThreadSafeWeakSet >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or zero if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements"

	| element start finish |

	finish := array size.
	start := ((self hashBlock value: anObject) \\ finish) + 1.
	
	"Search from (hash mod size) to the end."
	start to: finish do:
		[:index | 
		element := array at: index.
		(element == flag or: [element ~~ nil and: [self equalBlock value: element value: anObject]])
			ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do:
		[:index | 
		element := array at: index.
		(element == flag or: [element ~~ nil and: [self equalBlock value: element value: anObject]])
			ifTrue: [^ index ]].

	^ 0  "No match AND no empty slot"
]

{ #category : 'public' }
PluggableThreadSafeWeakSet >> slowSize [
	^self protected: [super slowSize]
]
