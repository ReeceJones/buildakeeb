module backend.parts.kbswitch;

import backend.parts.part;
import backend.structops;

/// tactile, clicky, or linear
/// What the fuck are you doing if its none of these?
enum SwitchType : int
{
    TACTILE = 0,
    CLICKY,
    LINEAR
}

/// Struct that represents a keyboard switch part.
struct KeyBoardSwitch
{
    mixin(inherit!KeyboardPart);
    string[]    forceCurves;    /// links to force curves of the switch
    int         actuationForce; /// actuation force of the switch
    int         bottomOutForce; /// bottom out force of the switch
    SwitchType  type;           /// The type of the switch
    int       smoothness;     /// how smooth a switch is on a scale of 1 to 10
    string      style;          /// the kind of switch
}

