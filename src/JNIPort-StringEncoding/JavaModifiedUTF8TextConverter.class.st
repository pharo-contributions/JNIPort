"
JavaModifiedUTF8TextConverter is used for mapping data streams where Character data is mapped using the variant of UTF-8 stream encoding as defined in the JNI 1.4.0 Specification included in the JDK 1.5.0, Chapter 3 ""JNI Types and Data Structures"", section ""Modified UTF-8 Strings"".

The spec describes the differences from UTF-8 as follows: ""There are two differences between this format and the standard UTF-8 format. First, the null character (char)0 is encoded using the two-byte format rather than the one-byte format. This means that modified UTF-8 strings never have embedded nulls. Second, only the one-byte, two-byte, and three-byte formats of standard UTF-8 are used. The Java VM does not recognize the four-byte format of standard UTF-8; it uses its own two-times-three-byte format instead.""

The implementation has an additional check mandated by The Unicode Standard Version 4.1: UTF-8 never produces more than 4 bytes per character, and the largest possible code point is 16r10FFFF. JavaModifiedUTF8TextConverter replaces code points larger than the largest Unicode code point 16r10FFFF by ""Character illegalCode"" (16rFFFF). For supplementary characters, i.e. characters with code points in the range from 16r10000 to 16r10FFFF, two 3-byte surrogate code point encodings are used as defined in the JNI specification.

For additional information concerning supplementary characters in Java see http://java.sun.com/developer/technicalArticles/Intl/Supplementary/

"
Class {
	#name : 'JavaModifiedUTF8TextConverter',
	#superclass : 'TextConverter',
	#category : 'JNIPort-StringEncoding-Imported',
	#package : 'JNIPort-StringEncoding',
	#tag : 'Imported'
}

{ #category : 'utilities' }
JavaModifiedUTF8TextConverter class >> encodingNames [

	^ #('JavaModifiedUTF-8' 'JavaModifiedUTF8') copy.

]

{ #category : 'private' }
JavaModifiedUTF8TextConverter >> basicNextFrom: aStream [ 
	"Reads a character from aStream. Does not substitute surrogate characters, this is done in #nextFrom:."

	| c1 c2 c3 |
	c1 := aStream next.
	c1 == nil ifTrue: [^nil].
	c1 := c1 codePoint.
	16r7F >= c1 ifTrue: [^Character value: c1].	"1-byte character"
	16rC0 == (c1 bitAnd: 16rE0) 
		ifTrue: 
			["2-byte character"

			c2 := aStream next.
			c2 == nil ifTrue: [^nil].
			c2 := c2 codePoint.
			^Character value: ((c1 bitAnd: 16r1F) bitShift: 6) + (c2 bitAnd: 16r3F)].
	16rE0 == (c1 bitAnd: 16rF0) 
		ifTrue: 
			["3-byte character"

			| codePoint |
			c2 := aStream next.
			c2 == nil ifTrue: [^nil].
			c2 := c2 codePoint.
			c3 := aStream next.
			c3 == nil ifTrue: [^nil].
			c3 := c3 codePoint.
			codePoint := ((c1 bitAnd: 16r0F) bitShift: 12) 
						+ ((c2 bitAnd: 16r3F) bitShift: 6) + (c3 bitAnd: 16r3F).
			^Character value: (16r10FFFF < codePoint 
						ifTrue: [16rFFFF "illegal character"]
						ifFalse: [codePoint])].
	^Character value: 16rFFFF "illegal character"
]

{ #category : 'conversion' }
JavaModifiedUTF8TextConverter >> characterSize: aCharacter [ 
	"Returns the size in bytes of aCharacter. For code points larger than the largest Unicode code point 16r10FFFF, answers the byte size for Character illegalCode. For supplementary characters, i.e. characters with code points in the range 16r10000 to 16r10FFFF, the answer is 6 bytes, as these characters are represented by two 3-byte surrogate code points. The null character is encoded by two bytes."

	| val |
	val := aCharacter asInteger.
	0 = val ifTrue: [^2].
	16r10FFFF < val ifTrue: [val := 16rFFFF].
	^16r007F >= val 
		ifTrue: [1]
		ifFalse: 
			[16r07FF >= val 
				ifTrue: [2]
				ifFalse: [16rFFFF >= val ifTrue: [3] ifFalse: [6]]]
]

{ #category : 'friend' }
JavaModifiedUTF8TextConverter >> leadingChar [

	^ self shouldNotImplement

]

{ #category : 'conversion' }
JavaModifiedUTF8TextConverter >> nextFromStream: aStream [ 
	"Decodes the next byte(s) in the UTF encoded stream, and answers the character. If the bytes read are a trailing surrogate (without preceding leading surrogate), then skip it and decode the next bytes. If the bytes read represent a leading surrogate, also decode the following bytes. If they are a trailing surrogate, answer the supplementary character represented by combining the two surrogates. If the character after a leading surrogate is not a trailing surrogate, then skip the leading surrogate and answer the character following it."

	| character leadingSurrogate |
	character := self basicNextFrom: aStream.
	character == nil ifTrue: [^nil].
	"Skip leading surrogates which are followed by another leading surrogate. Look for the next character which is not a leading surrogate."
	leadingSurrogate := nil.
	[character isLeadingSurrogate] whileTrue: 
			[leadingSurrogate := character.
			character := self basicNextFrom: aStream.
			character == nil 
				ifTrue: 
					[^nil	"There have been only leading surrogates so far, and the end of the stream has been reached. There is no valid character to answer."]].
	^(leadingSurrogate ~~ nil and: [character isTrailingSurrogate]) 
		ifTrue: [character := Character combineSurrogate: leadingSurrogate with: character]
		ifFalse: 
			["Skip isolated trailing surrogates."

			[character isTrailingSurrogate] whileTrue: 
					[character := self basicNextFrom: aStream.
					character == nil 
						ifTrue: 
							[^nil	"There have been only trailing surrogates so far, and the end of the stream has been reached. There is no valid character to answer."]].
			character]
]

{ #category : 'conversion' }
JavaModifiedUTF8TextConverter >> nextPut: aCharacter toStream: aStream [ 
	"Encodes aCharacter and writes it to aStream. Replaces Characters with code points larger than the largest legal value by the code point representing illegal Characters."

	| codePoint |
	codePoint := aCharacter asInteger.
	16r10FFFF < codePoint ifTrue: [codePoint := 16rFFFF].
	0 = codePoint 
		ifTrue: 
			[self nextPutNullOn: aStream.
			^aCharacter].
	16r007F >= codePoint 
		ifTrue: 
			[self nextPutOneByte: codePoint on: aStream.
			^aCharacter].
	16r7FF >= codePoint 
		ifTrue: 
			[self nextPutTwoBytes: codePoint on: aStream.
			^aCharacter].
	16rFFFF >= codePoint 
		ifTrue: 
			[self nextPutThreeBytes: codePoint on: aStream.
			^aCharacter].
	"codePoint >= 0x10000 - replace supplementary character with surrogates"
	self nextPutSurrogatesFor: codePoint on: aStream.
	^aCharacter
]

{ #category : 'private' }
JavaModifiedUTF8TextConverter >> nextPutNullOn: aStream [ 
	"Writes the encoding for a null Character to aStream."

	aStream
		nextPut: (Character value: 2r11000000);
		nextPut: (Character value: 2r10000000)
]

{ #category : 'private' }
JavaModifiedUTF8TextConverter >> nextPutOneByte: anInteger on: aStream [ 
	"Writes the one-byte encoding for the code point anInteger to aStream."

	aStream nextPut: (Character value: anInteger)
]

{ #category : 'private' }
JavaModifiedUTF8TextConverter >> nextPutSurrogatesFor: anInteger on: aStream [ 
	"Writes the two 3-byte encoded surrogate code points for the code point anInteger to aStream. The algorithm is a direct translation of the specification in the JNI spec."

	"Uncomment the following statements for testing if the algorithm produces valid leading and trailing surrogate code points:"
	"| c1 c2 c3 codePoint |
	c1 := 2r11101101.
	c2 := 2r10100000 + ((anInteger bitShift: -16) bitAnd: 2r00001111).
	c3 := 2r10000000 + ((anInteger bitShift: -10) bitAnd: 2r00111111).
	codePoint := ((c1 bitAnd: 16r0F) bitShift: 12) + ((c2 bitAnd: 16r3F) bitShift: 6) + (c3 bitAnd: 16r3F).
	self jniAssert: ((Character value: codePoint) isLeadingSurrogate).
	c1 := 2r11101101.
	c2 := 2r10110000 + ((anInteger bitShift: -6) bitAnd: 2r00001111).
	c3 := 2r10000000 + (anInteger bitAnd: 2r00111111).
	codePoint := ((c1 bitAnd: 16r0F) bitShift: 12) + ((c2 bitAnd: 16r3F) bitShift: 6) + (c3 bitAnd: 16r3F).
	self jniAssert: ((Character value: codePoint) isTrailingSurrogate)."

	aStream
		nextPut: (Character value: 2r11101101);
		nextPut: (Character value: 2r10100000 + ((anInteger bitShift: -16) - 1 bitAnd: 2r00001111));
		nextPut: (Character value: 2r10000000 + ((anInteger bitShift: -10) bitAnd: 2r00111111));
		nextPut: (Character value: 2r11101101);
		nextPut: (Character value: 2r10110000 + ((anInteger bitShift: -6) bitAnd: 2r00001111));
		nextPut: (Character value: 2r10000000 + (anInteger bitAnd: 2r00111111))
]

{ #category : 'private' }
JavaModifiedUTF8TextConverter >> nextPutThreeBytes: anInteger on: aStream [ 
	"Writes the three-byte encoding for the code point anInteger to aStream."

	aStream
		nextPut: (Character value: 2r11100000 + (anInteger bitShift: -12));
		nextPut: (Character value: 2r10000000 + ((anInteger bitShift: -6) bitAnd: 2r00111111));
		nextPut: (Character value: 2r10000000 + (anInteger bitAnd: 2r00111111))
]

{ #category : 'private' }
JavaModifiedUTF8TextConverter >> nextPutTwoBytes: anInteger on: aStream [ 
	"Writes the two-byte encoding for the code point anInteger to aStream."

	aStream
		nextPut: (Character value: 2r11000000 + (anInteger bitShift: -6));
		nextPut: (Character value: 2r10000000 + (anInteger bitAnd: 2r00111111))
]
