module backend.parts.kbcase;

import backend.parts.part;
import backend.structops;

/// A keyboard case
struct KeyboardCase
{
	mixin(inherit!KeyboardPart);
	string[] formFactor;		/// The form factor that this case is
	string[] compatibilityClass;	/// The classes this case is compatible with
	string[] layoutSupport;		/// the layouts this case supports
}

