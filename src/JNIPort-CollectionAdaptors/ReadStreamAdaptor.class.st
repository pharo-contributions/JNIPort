"
Adaptor to make any subject which understands <#atEnd #next> function as a readable stream; if it also understands #do: or #contents then it also forwards those.

"
Class {
	#name : 'ReadStreamAdaptor',
	#superclass : 'Stream',
	#instVars : [
		'subject'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
ReadStreamAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #atEnd: and #next: to it.  If it
	also understands #do:, #next:into:startingAt:, or #contents then they are also forwarded"

	^ (self basicNew)
		subject: anObject;
		yourself.
]

{ #category : 'testing' }
ReadStreamAdaptor >> atEnd [
	"one of the root methods for <ReadStream>"

	^ subject atEnd.
]

{ #category : 'status' }
ReadStreamAdaptor >> close [
	(subject respondsTo: #close) ifTrue: [subject close].
	subject := nil
]

{ #category : 'accessing' }
ReadStreamAdaptor >> contents [
	"if our subject understands #contents then answer the result of forwarding to it,
	otherwise throw an error"

	^subject contents
]

{ #category : 'enumerating' }
ReadStreamAdaptor >> do: a1Block [
	"if our subject understands #do: then answer the result of forwarding to it,
	otherwise execure the loop ourselves"

	^ (subject respondsTo: #do:)
		ifTrue: [subject do: a1Block]
		ifFalse: [super do: a1Block].
]

{ #category : 'accessing' }
ReadStreamAdaptor >> flush [
	"subclass responsibility - do nothing, this is for compatibility with BufferedExternalStreams."
]

{ #category : 'testing' }
ReadStreamAdaptor >> isReadable [
	"Answer whether the stream implements #next."

	^true
]

{ #category : 'testing' }
ReadStreamAdaptor >> isWritable [
	"Answer whether the stream implements #nextPut:."

	^false
]

{ #category : 'accessing' }
ReadStreamAdaptor >> next [
	"one of the root methods for <ReadStream>"

	^ subject next.
]

{ #category : 'accessing' }
ReadStreamAdaptor >> nextPut: anObject [ 
	"Provide an error notification that the receiver does not implement this message."

	self shouldNotImplement
]

{ #category : 'initializing' }
ReadStreamAdaptor >> subject: anObject [ 
	"private -- set the object to which we forward the basic stream messages"

	subject := anObject
]
