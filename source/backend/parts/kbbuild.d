module backend.parts.kbbuild;

import backend.parts;
import backend.structops;

struct KeyboardBuild
{
    KeyboardCase kbcase;                /// The case that they are using
    KeyboardPlate kbplate;              /// The plate that they are going to use
    KeyboardPCB kbpcb;                  /// The PCB that they are going to use
    KeyBoardSwitch[] kbswitches;        /// The switches that they are going to use. (They can use multiple different switches)
    KeyboardKeycap[] kbkeycaps;         /// The keycaps that they re going to use. (The can use multiple different keysets)
    KeyboardAccessory[] kbaccessories;  /// The various accessories that they want to get with their keyboard.
}
