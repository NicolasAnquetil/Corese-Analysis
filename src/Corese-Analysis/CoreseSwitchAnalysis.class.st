Class {
	#name : 'CoreseSwitchAnalysis',
	#superclass : 'Object',
	#instVars : [
		'famixModel',
		'noSwitches',
		'switchesFound',
		'switchStatementPattern'
	],
	#category : 'Corese-Analysis',
	#package : 'Corese-Analysis'
}

{ #category : 'as yet unclassified' }
CoreseSwitchAnalysis >> allSwitches: aType [

	| result |
	self initializeSwitchPattern.

	switchesFound := OrderedCollection new.
	noSwitches := OrderedCollection new.

	aType typedEntities do: [ :aVar |
		({ FamixJavaParameter . FamixJavaLocalVariable } includes: aVar class)
		ifTrue: [
			result := switchStatementPattern match: aVar parentBehaviouralEntity generateFastAndBind.
			(result isMatch and:
			[ result matchingContexts anySatisfy: [ :ctxt | (ctxt bindings at: 'found') = aType ] ] )
			ifTrue: [ switchesFound add: aVar parentBehaviouralEntity ]
			ifFalse: [ noSwitches add: aVar parentBehaviouralEntity ].
			
		]
	]
]

{ #category : 'as yet unclassified' }
CoreseSwitchAnalysis >> initializeSwitchPattern [

	switchStatementPattern := (FASTJavaModel % {
		#'entities' <=> FASTJavaSwitchStatement % {
			#'condition' <=> FASTJavaVariableExpression % {
				#'famixVariable>declaredType' <=> #'@found'
			}
		}
	}) asMatcher.

]
