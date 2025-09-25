Extension { #name : 'String' }

{ #category : '*JNIPort-StringEncoding' }
String >> asJavaLangStringEncodedByteArray [
	"Answer the receiver as a ByteArray encoded as a java.lang.String."

	| converter |
	converter := UTF16TextConverter new.
	converter useLittleEndian: EndianDetector isLittleEndian.
	^(self convertToWithConverter: converter) asByteArray
]

{ #category : '*JNIPort-StringEncoding' }
String >> asJavaModifiedUTF8EncodedByteArray [
	"Answer the receiver as a ByteArray encoded in the variant of UTF8 that
	is used in JNI and the JVM classfile format."

	^self asJavaModifiedUTF8EncodedString asByteArray
]

{ #category : '*JNIPort-StringEncoding' }
String >> asJavaModifiedUTF8EncodedString [
	"Answer the receiver as a String encoded in the variant of UTF8 that
	is used in JNI and the JVM classfile format."

	^ self convertToWithConverter: JavaModifiedUTF8TextConverter new
]

{ #category : '*JNIPort-StringEncoding' }
String class >> fromJavaLangStringEncodedByteArray: aByteArray [
	"Answer a new instance of the receiver initialised by decoding the java.lang.String encoded byte array."

	| converter |
	converter := UTF16TextConverter new.
	converter useLittleEndian: EndianDetector isLittleEndian.
	^aByteArray asString convertFromWithConverter: converter
]

{ #category : '*JNIPort-StringEncoding' }
String class >> fromJavaModifiedUTF8EncodedByteArray: aByteArray [
	"Answer a new instance of the receiver initialised by decoding the Java modified UTF8
	encoded byte array."

	^aByteArray asString convertFromWithConverter: JavaModifiedUTF8TextConverter new
]
