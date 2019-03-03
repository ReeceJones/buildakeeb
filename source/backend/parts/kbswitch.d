module backend.parts.kbswitch;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;

/// tactile, clicky, or linear
/// What the fuck are you doing if its none of these?
enum SwitchType : int
{
    TACTILE = 0,
    CLICKY,
    LINEAR
}

final class KeyboardSwitch : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "switch");
    }
    ~this()
    {
        _forceCurves = [];
        _style = "";
    }
    @property ref string[] forceCurves() { return _forceCurves; }
    @property ref int actuationForce() { return _actuationForce; }
    @property ref int bottomOutForce() { return _bottomOutForce; }
    @property ref SwitchType type() { return _type; }
    @property ubyte smoothness() { return smoothness; }
    @property void smoothness(ubyte i) 
    {
        if (i > 10) throw new PartException("invalid range");
        else _smoothness = i;
    }
    @property ref string style() { return _style; }

    override Bson serialize()
    {
        auto bson = this.defaultBson();
        bson["forceCurves"] = _forceCurves.map!(a => Bson(a)).array;
        bson["actuationForce"] = Bson(_actuationForce);
        bson["bottomOutForce"] = Bson(_bottomOutForce);
        bson["type"] = Bson(cast(int)_type);
        bson["smoothness"] = Bson(_smoothness);
        bson["style"] = Bson(_style);
        return bson;
    }
private:
    string[]    _forceCurves;
    int         _actuationForce;
    int         _bottomOutForce;
    SwitchType  _type;
    ubyte       _smoothness;
    string      _style;
}
