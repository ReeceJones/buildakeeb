module backend.parts.kbbuild;

import backend.parts;

class KeyboardBuild
{
public:
    this()
    {
        
    }
    @property ref KeyboardSwitch[] switches()       { return _switches; }
    @property ref KeyboardPCB[] pcbs()              { return _pcbs; }
    @property ref KeyboardPlate[] plates()          { return _plates; }
    @property ref KeyboardCase[] cases()            { return _cases; }
    @property ref KeyboardKeycap[] keycaps()        { return _keycaps; }
    @property ref KeyboardAccessory[] accessories() { return _accessories; }
    @property ref string layout()                   { return _layout; }
private:
    KeyboardSwitch[]    _switches;
    KeyboardPCB[]       _pcbs;
    KeyboardPlate[]     _plates;
    KeyboardCase[]      _cases;
    KeyboardKeycap[]    _keycaps;
    KeyboardAccessory[] _accessories;
    string              _layout;
}
