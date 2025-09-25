Extension { #name : 'SequenceableCollection' }

{ #category : '*JNIPort-SqueakCommon-Extensions' }
SequenceableCollection >> copyReplacing: oldElement withObject: newElement [ 
	^self copyReplaceAll: (Array with: oldElement)
		with: (Array with: newElement)
]

{ #category : '*JNIPort-SqueakCommon-Extensions' }
SequenceableCollection >> from: aStartIndex to: aStopIndex keysAndValuesDo: a2Block [
	^ aStartIndex to: aStopIndex do: [ :i | a2Block value: i value: (self at: i) ]
]
