module backend.parts.kbbuild;

import backend.parts;
import backend.structops;

/// Struct that represents a keyboard build
struct KeyboardBuild
{
    KeyboardCase kbcase;                /// The case that they are using
    KeyboardPlate kbplate;              /// The plate that they are going to use
    KeyboardPCB kbpcb;                  /// The PCB that they are going to use
    KeyBoardSwitch[] kbswitches;        /// The switches that they are going to use. (They can use multiple different switches)
    KeyboardKeycap[] kbkeycaps;         /// The keycaps that they re going to use. (The can use multiple different keysets)
    KeyboardAccessory[] kbaccessories;  /// The various accessories that they want to get with their keyboard.
}


/// Struct that represents the result of a build verification
struct BuildResult
{
    bool success;   /// Whether or not the build is valid
    string message = ""; /// The message of why the build is not valid. This should be empty if the build is valid
}

/// Verifies that a build's parts are compatible
BuildResult verify(KeyboardBuild kbbuild)
{
    // first we want to ensure that the form factor of the case, plate, and pcb matches
    
    // second we want to ensue the the switches are compatible with the plate and the pcb

    // third we want to make sure that the plate, case, and pcb share a compatibility class
    
    // fourth we want to make sure that the keycaps are compatible with the switches

    // success

    return BuildResult(true);
}

private:

BuildResult verifyFormFactor(KeyboardBuild kbbuild)
{
	enum isz = KeyboardPart.sizeof;

	return BuildResult(true);
}



