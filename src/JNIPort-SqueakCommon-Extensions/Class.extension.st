Extension { #name : 'Class' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
Class >> constructEventsTriggered [
	"Construct a Set with the names of all events triggered by instances of this class.
	Not actually needed in Pharo/Squeak, this method exists only to avoid code critic
	warnings for methods in subclasses which contain a super send."
	
	^Set new: 20
]
