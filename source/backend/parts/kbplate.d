module backend.parts.kbplate;

import backend.parts.part;
import backend.structops;

/// Struct that represents a keyboard plate
struct KeyboardPlate
{
    mixin(inherit!KeyboardPart);
    string formFactor;              /// The form factor of the plate
    string plateStyle;              /// Ex: half-plate, full-plate
    string material;                /// The material that the plate is made out of
    string[] switchStyleSupport;    /// The style of switches that the plate supports
    string[] compatibilityClass;    /// Compatibility classes
    string[] layout;                /// The layouts that the plate supports
}

