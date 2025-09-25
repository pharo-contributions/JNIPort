Extension { #name : 'String' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
String >> asClassOrNilIn: anEnvironment [
	"Answers a class in anEnvironment (a SystemDictionary) with a name equal to the receiver, or nil if no such class is found."

	^anEnvironment at: self asSymbol ifAbsent: [nil]
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
String class >> lineDelimiter [
	| platform |
	platform := Smalltalk os platformName.
	platform = 'unix'
		ifTrue: [ ^ self lf ].
	platform = 'Win32'
		ifTrue: [ ^ self crlf ].
	(platform = 'Mac OS' and: [ (Smalltalk os osVersion beginsWith: 'darwin') not ])
		ifTrue: [ ^ self lf ].
	^ self cr
]
