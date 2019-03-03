module backend.parts.kbplate;

import backend.parts.part;
import vibe.data.bson;
import std.algorithm: map;
import std.array: array;
import std.stdio;

class KeyboardPlate : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "plates");
    }
    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount,
            string formFactor, string plateStyle, string material, string[] switchStyleSupport, string[] compatibilityClass, string[] layout)
    {
        super("build-a-keeb-parts", "plates", tags, partId, productLinks, images, description, amount);
        

        _formFactor = formFactor;
        _plateStyle = plateStyle;
        _material = material;
        _switchStyleSupport = switchStyleSupport;
        _compatibilityClass = compatibilityClass;
        _layout = layout;

        try {
            this.insert();
        } catch(PartException pex) {
            writeln("could not insert part: ", pex.msg);
        }
    }
    this(string link)
    {
        Bson result;
        super("build-a-keeb-parts", "plates", link, result);
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

unittest
{
    writeln("creating accessory object");
    auto plate = new KeyboardPlate(["o-rings", "silent"],
                        PartIdentification(["wasdkeyboards"], "unknown", "0.2mm O-rings", [Configuration("color", ["red", "blue"])]),
                        [ProductLink("wadkeyboards.com", "I cant be bothered", 3.45)],
                        ["I really cant be bothered"], "# O-rings\nOrings are cool but also bad", 
                        1,
                        "60%", "full", "aluminum", ["Mx"], ["universal", "tofu"], ["universal"]);
}



