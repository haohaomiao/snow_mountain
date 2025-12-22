extends Node

enum Phase{
    DEFAULT,
    SKI,
    BAR,
    ENDING,
}

var day: int = 1
var flags := {}
var phase: Phase = Phase.DEFAULT
