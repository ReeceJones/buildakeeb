module backend.parts.kbpcb;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;
import std.stdio;


class KeyboardPCB : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "pcbs");
    }

    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount,
            string formFactor, string[] switchStyleSupport, string[] compatibilityClass, string[] layoutSupport)
    {
        super("build-a-keeb-parts", "pcbs", tags, partId, productLinks, images, description, amount);
        

        _formFactor = formFactor;
        _switchStyleSupport = switchStyleSupport;
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
        super("build-a-keeb-parts", "pcbs", link, result);
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

unittest
{
    writeln("creating accessory object");
    auto pcb = new KeyboardPCB(["o-rings", "silent"],
                        PartIdentification(["wasdkeyboards"], "unknown", "0.2mm O-rings", [Configuration("color", ["red", "blue"])]),
                        [ProductLink("wadkeyboards.com", "I cant be bothered", 3.45)],
                        ["I really cant be bothered"], "# O-rings\nOrings are cool but also bad", 
                        1,
                        "60%", ["Mx, ALPS"], ["universial", "tofu"], ["wkl", "hkhb", "iso", "ansi"]);
}

