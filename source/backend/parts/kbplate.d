module backend.parts.kbplate;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;

class KeyboardPlate : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "plate");
    }
    @property ref string formFactor() { return _formFactor; }
    @property ref string plateStyle() { return _plateStyle; }
    @property ref string material() { return _material; }
    @property ref string[] switchStyleSupport() { return _switchStyleSupport; }
    @property ref string[] compatibilityClass() { return _compatibilityClass; }
    @property ref string[] layout() { return _layout; }
    override Bson serialize()
    {
        auto bson = this.defaultBson();
        bson["formFactor"] = Bson(_formFactor);
        bson["plateStyle"] = Bson(_plateStyle);
        bson["material"] = Bson(_material);
        bson["switchStyleSupport"] = _switchStyleSupport.map!(a => Bson(a)).array;
        bson["compatibilityClass"] = _compatibilityClass.map!(a => Bson(a)).array;
        bson["layout"]             = _layout.map!(a => Bson(a)).array;
        return bson;
    }
private:
    string      _formFactor;
    string      _plateStyle;
    string      _material;
    string[]    _switchStyleSupport;
    string[]    _compatibilityClass;
    string[]    _layout;
}

