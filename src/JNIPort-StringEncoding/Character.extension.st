Extension { #name : 'Character' }

{ #category : '*JNIPort-StringEncoding' }
Character class >> combineSurrogate: leadingSurrogate with: trailingSurrogate [ 
	"Combine the leading and trailing surrogate code points (which are Integers) to the corresponding supplementary character. The algorithm is taken from the UTF-16 FAQ at http://www.unicode.org/unicode/faq/utf_bom.html#35

	const UTF32 SURROGATE_OFFSET = 0x10000 - (0xD800 << 10) - 0xDC00;	// result: -56613888
	UTF32 codepoint = (lead << 10) + trail + SURROGATE_OFFSET;"

	| codePoint |
	codePoint := (leadingSurrogate asInteger bitShift: 10) + trailingSurrogate asInteger
				- 56613888.	"SURROGATE_OFFSET"
	^self value: codePoint
]

{ #category : '*JNIPort-StringEncoding' }
Character >> isLeadingSurrogate [
	"Answers if the receiver is in the leading surrogate range, i.e. its code point is between 16rD800 and 16rDBFF."

	^self charCode between: 16rD800 and: 16rDBFF
]

{ #category : '*JNIPort-StringEncoding' }
Character >> isSupplementary [
	"Answers if the receiver is a supplementary Character according to Unicode 4.0, i.e. if its code point is larger than 0xFFFF, but not larger than the largest legal code point 0x10FFFF."

	^self charCode between: 16r10000 and: 16r10FFFF
]

{ #category : '*JNIPort-StringEncoding' }
Character >> isTrailingSurrogate [ 
	"Answers if the receiver is in the trailing surrogate range, i.e. its code point is between 16rDC00 and 16rDFFF."

	^self charCode between: 16rDC00 and: 16rDFFF
]

{ #category : '*JNIPort-StringEncoding' }
Character >> leadingSurrogate [
	"Answers the leading surrogate code point (an Integer) for the receiver, if it is a supplementary character, otherwise raises an Error. The algorithm is taken from the UTF-16 FAQ at http://www.unicode.org/unicode/faq/utf_bom.html#35

	const UTF32 LEAD_OFFSET = 0xD800 - (0x10000 >> 10);	//  result: 16rD7C0 or 55232
	UTF16 lead = LEAD_OFFSET + (codepoint >> 10);
	UTF16 trail = 0xDC00 + (codepoint & 0x3FF);"

	self isSupplementary 
		ifFalse: [^self error: 'Only supplementary characters have surrogates.'].
	^16rD7C0 + (self charCode bitShift: -10)
]

{ #category : '*JNIPort-StringEncoding' }
Character >> trailingSurrogate [
	"Answers the trailing surrogate code point (an Integer) for the receiver, if it is a supplementary character, otherwise raises an Error. The algorithm is taken from the UTF-16 FAQ at http://www.unicode.org/unicode/faq/utf_bom.html#35

	const UTF32 LEAD_OFFSET = 0xD800 - (0x10000 >> 10);	//  result: -67053568
	UTF16 lead = LEAD_OFFSET + (codepoint >> 10);
	UTF16 trail = 0xDC00 + (codepoint & 0x3FF);"

	self isSupplementary 
		ifFalse: [^self error: 'Only supplementary characters have surrogates.'].
	^16rDC00 + (self charCode bitAnd: 16r03FF)
]
