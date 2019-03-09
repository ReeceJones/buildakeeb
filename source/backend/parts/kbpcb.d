module backend.parts.kbpcb;

import backend.parts.part;
import backend.structops;

/// A keyboard's PCB (printed circuit board)
struct KeyboardPCB
{
	mixin(inherit!KeyboardPart);
	string formFactor;		/// What form factor is the keyboard pcb
	string[] switchStyleSupport;	/// The styles of keyboard switch that the PCB supports
	string[] compatibilityClass;	/// Compatibility classes
	string[] layoutSupport;		/// Layouts that it supports
}

