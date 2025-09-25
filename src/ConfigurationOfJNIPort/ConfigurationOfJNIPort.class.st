"
From ConfigurationOfJNIPort-TudorGirba.3.9 of http://www.smalltalkhub.com/JNIPort/JNIPort/mc/
"
Class {
	#name : 'ConfigurationOfJNIPort',
	#superclass : 'ConfigurationOf',
	#category : 'ConfigurationOfJNIPort',
	#package : 'ConfigurationOfJNIPort'
}

{ #category : 'metacello tool support' }
ConfigurationOfJNIPort class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : 'loading' }
ConfigurationOfJNIPort class >> load [
	"self load"

	^(self project version: '3.0-alpha') load
]

{ #category : 'baselines' }
ConfigurationOfJNIPort >> baseline30: spec [ 
	<version: '3.0-baseline'>
	
	spec for: #pharo do: [
		spec repository: 'http://www.smalltalkhub.com/mc/JNIPort/JNIPort/main'.	
		spec blessing: #baseline.
		spec description: 'JNIPort 3.0 for Pharo'. 
		spec author: 'JoachimGeidel'.
		spec 
			package: 'JNIPort-SqueakCommon-Extensions';
			package: 'JNIPort-CollectionAdaptors' 
				with: [ spec requires: #('JNIPort-SqueakCommon-Extensions') ];
			package: 'JNIPort-StringEncoding' 
				with: [ spec requires: #('JNIPort-SqueakCommon-Extensions') ];
			package: 'JNIPort-GhostClasses' 
				with: [ spec requires: #('JNIPort-SqueakCommon-Extensions') ];
			package: 'JNIPort-StandardLibInterface' 
				with: [ spec requires: #('JNIPort-SqueakCommon-Extensions') ];
			package: 'JNIPort-JNI' with: [ spec requires: #(
				'JNIPort-CollectionAdaptors' 
				'JNIPort-StringEncoding'
				'JNIPort-GhostClasses'
				'JNIPort-StandardLibInterface'
				) ];
			package: 'JNIPort-JNIHelper' 
				with: [ spec requires: #('JNIPort-JNI') ];
			package: 'JNIPort-Java-Base' 
				with: [ spec requires: #('JNIPort-JNI') ];
			package: 'JNIPort-Java-AdditionalWrappers' 
				with: [ spec requires: #('JNIPort-Java-Base') ];
			package: 'JNIPort-Java-WrapperGeneration' 
				with: [ spec requires: #('JNIPort-Java-Base') ];
			package: 'JNIPort-Java-GhostClasses' 
				with: [ spec requires: #('JNIPort-Java-WrapperGeneration') ];
			package: 'JNIPort-Java-Callbacks' 
				with: [ spec requires: #('JNIPort-Java-Base') ];
			package: 'JNIPort-SqueakCommon-Compatibility' 
				with: [ spec requires: #('JNIPort-Java-Base' 'JNIPort-Java-GhostClasses') ];
			package: 'JNIPort-Tests-Prerequisites' with: [ spec requires: #(
				'JNIPort-SqueakCommon-Extensions' 
				'JNIPort-CollectionAdaptors' 
				'JNIPort-StringEncoding'
				'JNIPort-GhostClasses'
				'JNIPort-StandardLibInterface'
				) ];
			package: 'JNIPort-Tests-Java-Base' 
				with: [ spec requires: #('JNIPort-Java-Base') ];
			package: 'JNIPort-Tests-Java-WrapperGeneration' 
				with: [ spec requires: #('JNIPort-Java-WrapperGeneration') ];
			package: 'JNIPort-Tests-Java-Callbacks' 
				with: [ spec requires: #('JNIPort-Java-Callbacks') ].
		spec
			group: 'default' with: #('Prereqs' 'Core');			
			group: 'All' with: #('Prereqs' 'Core' 'Tests');
			group: 'Prereqs' with: #(
				'JNIPort-SqueakCommon-Extensions' 
				'JNIPort-CollectionAdaptors' 
				'JNIPort-StringEncoding' 
				'JNIPort-GhostClasses' 
				'JNIPort-StandardLibInterface'
				);
			group: 'Core' with: #(
				'JNIPort-JNI'
				'JNIPort-JNIHelper'
				'JNIPort-Java-Base'
				'JNIPort-Java-AdditionalWrappers'
				'JNIPort-Java-WrapperGeneration'
				'JNIPort-Java-GhostClasses'
				'JNIPort-Java-Callbacks'
				'JNIPort-SqueakCommon-Compatibility'
				);
			group: 'Tests' with: #(
				'JNIPort-Tests-Prerequisites'
				'JNIPort-Tests-Java-Base'
				'JNIPort-Tests-Java-WrapperGeneration'
				'JNIPort-Tests-Java-Callbacks'
				). ].
]

{ #category : 'symbolic versions' }
ConfigurationOfJNIPort >> development: spec [
	<symbolicVersion: #'development'>

	spec for: #'pharo5.x' version: '3.1-alpha'.
	spec for: #'pharo3.x' version: '3.0-alpha'
]

{ #category : 'symbolic versions' }
ConfigurationOfJNIPort >> stable: spec [
	<symbolicVersion: #'stable'>

	spec for: #'pharo5.x' version: '3.1-alpha'.
	spec for: #'pharo3.x' version: '3.0-alpha'
]

{ #category : 'versions' }
ConfigurationOfJNIPort >> version30alpha: spec [ 
	<version: '3.0-alpha' imports: #('3.0-baseline') >
	
	spec for: #pharo do: [
		spec blessing: #development.
		spec 
			package: 'JNIPort-SqueakCommon-Extensions' with: 'JNIPort-SqueakCommon-Extensions-JoachimGeidel.3.0a3';
			package: 'JNIPort-CollectionAdaptors' with: 'JNIPort-CollectionAdaptors-JoachimGeidel.3.0a2';
			package: 'JNIPort-StringEncoding' with: 'JNIPort-StringEncoding-JoachimGeidel.2.0';
			package: 'JNIPort-GhostClasses' with: 'JNIPort-GhostClasses-JoachimGeidel.3.0a4';
			package: 'JNIPort-StandardLibInterface' with: 'JNIPort-StandardLibInterface-JoachimGeidel.3.0a3';
			package: 'JNIPort-JNI' with: 'JNIPort-JNI-JoachimGeidel.3.0a24';
			package: 'JNIPort-JNIHelper' with: 'JNIPort-JNIHelper-JoachimGeidel.3.0a4';
			package: 'JNIPort-Java-Base' with: 'JNIPort-Java-Base-JoachimGeidel.3.0a16';
			package: 'JNIPort-Java-AdditionalWrappers' with: 'JNIPort-Java-AdditionalWrappers-JoachimGeidel.2.0';
			package: 'JNIPort-Java-WrapperGeneration' with: 'JNIPort-Java-WrapperGeneration-JoachimGeidel.3.0a2';
			package: 'JNIPort-Java-GhostClasses' with: 'JNIPort-Java-GhostClasses-JoachimGeidel.3.0a7';
			package: 'JNIPort-Java-Callbacks' with: 'JNIPort-Java-Callbacks-JoachimGeidel.3.0a5';
			package: 'JNIPort-SqueakCommon-Compatibility' with: 'JNIPort-SqueakCommon-Compatibility-JoachimGeidel.3.0a1';
			package: 'JNIPort-Tests-Prerequisites' with: 'JNIPort-Tests-Prerequisites-JoachimGeidel.3.0a6';
			package: 'JNIPort-Tests-Java-Base' with: 'JNIPort-Tests-Java-Base-JoachimGeidel.3.0a2';
			package: 'JNIPort-Tests-Java-WrapperGeneration' with: 'JNIPort-Tests-Java-WrapperGeneration-JoachimGeidel.3.0a2';
			package: 'JNIPort-Tests-Java-Callbacks' with: 'JNIPort-Tests-Java-Callbacks-JoachimGeidel.3.0a3'.
		].
]

{ #category : 'versions' }
ConfigurationOfJNIPort >> version31alpha: spec [ 
	<version: '3.1-alpha' imports: #('3.0-baseline') >
	
	spec for: #pharo do: [
		spec blessing: #development.
		spec 
			package: 'JNIPort-SqueakCommon-Extensions' with: 'JNIPort-SqueakCommon-Extensions-JoachimGeidel.3.0a3';
			package: 'JNIPort-CollectionAdaptors' with: 'JNIPort-CollectionAdaptors-JoachimGeidel.3.0a2';
			package: 'JNIPort-StringEncoding' with: 'JNIPort-StringEncoding-TudorGirba.2.1';
			package: 'JNIPort-GhostClasses' with: 'JNIPort-GhostClasses-TudorGirba.3.5';
			package: 'JNIPort-StandardLibInterface' with: 'JNIPort-StandardLibInterface-JoachimGeidel.3.0a3';
			package: 'JNIPort-JNI' with: 'JNIPort-JNI-JoachimGeidel.3.0a24';
			package: 'JNIPort-JNIHelper' with: 'JNIPort-JNIHelper-JoachimGeidel.3.0a4';
			package: 'JNIPort-Java-Base' with: 'JNIPort-Java-Base-TudorGirba.3.17';
			package: 'JNIPort-Java-AdditionalWrappers' with: 'JNIPort-Java-AdditionalWrappers-JoachimGeidel.2.0';
			package: 'JNIPort-Java-WrapperGeneration' with: 'JNIPort-Java-WrapperGeneration-JoachimGeidel.3.0a2';
			package: 'JNIPort-Java-GhostClasses' with: 'JNIPort-Java-GhostClasses-JoachimGeidel.3.0a7';
			package: 'JNIPort-Java-Callbacks' with: 'JNIPort-Java-Callbacks-JoachimGeidel.3.0a5';
			package: 'JNIPort-SqueakCommon-Compatibility' with: 'JNIPort-SqueakCommon-Compatibility-JoachimGeidel.3.0a1';
			package: 'JNIPort-Tests-Prerequisites' with: 'JNIPort-Tests-Prerequisites-JoachimGeidel.3.0a6';
			package: 'JNIPort-Tests-Java-Base' with: 'JNIPort-Tests-Java-Base-JoachimGeidel.3.0a2';
			package: 'JNIPort-Tests-Java-WrapperGeneration' with: 'JNIPort-Tests-Java-WrapperGeneration-JoachimGeidel.3.0a2';
			package: 'JNIPort-Tests-Java-Callbacks' with: 'JNIPort-Tests-Java-Callbacks-JoachimGeidel.3.0a3'.
		].
]

{ #category : 'accessing' }
ConfigurationOfJNIPort >> versionNumberClass [
    ^ MetacelloVersionNumber
]
