"
Adaptor to make any subject which understands <#atEnd #nextPut:> function as a readable stream; if the subject also understands #close or #contents then it also forwards those.

"
Class {
	#name : 'WriteStreamAdaptor',
	#superclass : 'Stream',
	#instVars : [
		'subject'
	],
	#category : 'JNIPort-CollectionAdaptors',
	#package : 'JNIPort-CollectionAdaptors'
}

{ #category : 'instance creation' }
WriteStreamAdaptor class >> for: anObject [
	"answer a new instance which wraps anObject and forwards #atEnd: and #nextPut: to it.
	If it also understands any of #close, #flush, #next:put:, #next:putAll:startingAt:, or #contents
	then they are also forwarded"

	^ (self basicNew)
		subject: anObject;
		yourself.
]

{ #category : 'testing' }
WriteStreamAdaptor >> atEnd [
	"one of the root methods for <WriteStream>"

	^subject atEnd
]

{ #category : 'status' }
WriteStreamAdaptor >> close [
	"one of the root methods for <WriteStream>"

	(subject respondsTo: #close) ifTrue: [subject close].
	subject := nil.
]

{ #category : 'accessing' }
WriteStreamAdaptor >> contents [
	"if our subject understands #contents then answer the result of forwarding to it,
	otherwise throw an error"

	^subject contents
]

{ #category : 'accessing' }
WriteStreamAdaptor >> flush [
	"subclass responsibility - do nothing, this is for compatibility with BufferedExternalStreams."
]

{ #category : 'testing' }
WriteStreamAdaptor >> isReadable [
	"Answer whether the stream implements #next."

	^false
]

{ #category : 'testing' }
WriteStreamAdaptor >> isWritable [
	"Answer whether the stream implements #nextPut:."

	^true
]

{ #category : 'accessing' }
WriteStreamAdaptor >> next [
	self shouldNotImplement
]

{ #category : 'accessing' }
WriteStreamAdaptor >> nextPut: anObject [
	"one of the root methods of <WriteStream>"

	^ subject nextPut: anObject.
]

{ #category : 'initializing' }
WriteStreamAdaptor >> subject: anObject [
	"private -- set the object to which we forward the basic stream messages"

	subject := anObject
]
