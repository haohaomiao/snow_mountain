extends Node

enum Phase{
	DEFAULT,
	SKI,
	BAR,
	ENDING,
}

var day: int = 1
var english: bool = true
var flags := {}
var phase: Phase = Phase.DEFAULT
