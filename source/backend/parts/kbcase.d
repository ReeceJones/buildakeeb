module backend.parts.kbcase;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;

import std.stdio;

class KeyboardCase : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "cases");
    }

    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount,
            string formFactor, string[] compatibilityClass, string[] layoutSupport)
    {
        super("build-a-keeb-parts", "cases", tags, partId, productLinks, images, description, amount);
        _formFactor = formFactor;
        _compatibilityClass = compatibilityClass;
        _layoutSupport = layoutSupport;

        try {
            this.insert();
        } catch(PartException pex) {
            writeln("could not insert part: ", pex.msg);
        }
    }
    this(string link)
    {
        Bson result;
        super("build-a-keeb-parts", "cases", link, result);
    }

    @property ref string formFactor() { return _formFactor; }
    @property ref string[] compatibilityClass() { return _compatibilityClass; }
    @property ref string[] layoutSupport() { return _layoutSupport; }

    override Bson serialize()
    {
        auto bson = this.defaultBson();
        bson["formFactor"] = Bson(_formFactor);
        // bson["compatibilityClass"] = Bson(_compatibilityClass);
        bson["comapatibilityClass"] = Bson(_compatibilityClass.map!(a => Bson(a)).array);
        bson["layoutSupport"] = Bson(_layoutSupport.map!(a => Bson(a)).array);
        return bson;
    }
private:
    string _formFactor;
    string[] _compatibilityClass;
    string[] _layoutSupport;
}

