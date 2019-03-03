module backend.parts.kbpcb;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;

class KeyboardPCB : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "pcb");
    }
    @property ref string formFactor() { return _formFactor; }
    @property ref string[] switchStyleSupport() { return _switchStyleSupport; }
    @property ref string[] compatibilityClass() { return _compatibilityClass; }
    @property ref string[] layoutSupport() { return _layoutSupport; }
    override Bson serialize()
    {
        auto bson = this.defaultBson();
        bson["formFactor"] = Bson(_formFactor);
        bson["switchStyleSupport"] = _switchStyleSupport.map!(a => Bson(a)).array;
        bson["compatibilityClass"] = _compatibilityClass.map!(a => Bson(a)).array;
        bson["layoutSupport"] = _layoutSupport.map!(a => Bson(a)).array;
        return bson;
    }
private:
    string _formFactor;
    string[] _switchStyleSupport;
    string[] _compatibilityClass;
    string[] _layoutSupport;
}

