module backend.parts.kbaccessory;

import backend.parts.part;
import backend.structops;


/// Struct that represents a miscellaneous
struct KeyboardAccessory
{
	mixin(inherit!KeyboardPart);
	string category;		/// The category of the accessory
	string[string] specifications;	/// various fields that the part contains
}

