module backend.parts.kbswitch;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;
import std.conv: text;

import std.stdio;

/// tactile, clicky, or linear
/// What the fuck are you doing if its none of these?
enum SwitchType : int
{
    TACTILE = 0,
    CLICKY,
    LINEAR
}


