module backend.parts.kbswitch;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;

import std.stdio;

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
        super("build-a-keeb-parts", "switches");
    }
    ~this()
    {
        _forceCurves = [];
        _style = "";
    }
    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount,
            string[] forceCurves, int actuationForce, int bottomOutForce, SwitchType type, ubyte smoothness, string style)
    {
        super("build-a-keeb-parts", "switches", tags, partId, productLinks, images, description, amount);
        

        _forceCurves = forceCurves;
        _actuationForce = actuationForce;
        _bottomOutForce = bottomOutForce;
        _type = type;
        _smoothness = smoothness;
        _style = style;

        try {
            this.insert();
        } catch(PartException pex) {
            writeln("could not insert part: ", pex.msg);
        }
    }
    this(string link)
    {
        Bson result;
        super("build-a-keeb-parts", "switches", link, result);
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

unittest
{
    writeln("creating accessory object");
    auto s = new  KeyboardSwitch(["o-rings", "silent"],
                        PartIdentification(["wasdkeyboards"], "unknown", "0.2mm O-rings", [Configuration("color", ["red", "blue"])]),
                        [ProductLink("wadkeyboards.com", "I cant be bothered", 3.45)],
                        ["I really cant be bothered"], "# O-rings\nOrings are cool but also bad", 
                        1,
                        [], 60, 80, SwitchType.CLICKY, 4, "Mx");
}


