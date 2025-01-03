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

{ #category : 'running' }
CoreseSwitchAnalysis class >> run [
	<script>

	self new
		run ;
		yourself.
]

{ #category : 'running' }
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

{ #category : 'accessing' }
CoreseSwitchAnalysis >> initializeSwitchPattern [

	switchStatementPattern := (FASTJavaModel % {
		#'entities' <=> FASTJavaSwitchStatement % {
			#'condition' <=> FASTJavaVariableExpression % {
				#'famixVariable>declaredType' <=> #'@found'
			}
		}
	}) asMatcher.

]

{ #category : 'running' }
CoreseSwitchAnalysis >> run [

	| model |
	model := MooseModel root allModels
		detect: [ :m | m name = 'corese' ]
		ifNone: [
			self inform: 'Corese model not found'.
			^self
		].
	self allSwitches: (model entityNamed: #'fr::inria::corese::core::Event')
]
