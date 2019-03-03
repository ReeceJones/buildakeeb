module backend.parts.kbkeycap;

import backend.parts.part;
import vibe.data.bson;
import std.stdio;

class KeyboardKeycap : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "keycaps");
    }

    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount,
            string profile, string mountStyle, string material)
    {
        super("build-a-keeb-parts", "keycaps", tags, partId, productLinks, images, description, amount);
        

        _profile = profile;
        _mountStyle = mountStyle;
        _material = material;

        try {
            this.insert();
        } catch(PartException pex) {
            writeln("could not insert part: ", pex.msg);
        }
    }
    this(string link)
    {
        Bson result;
        super("build-a-keeb-parts", "keycaps", link, result);
    }

    @property ref string profile() { return _profile; }
    @property ref string mountStyle() { return _mountStyle; }
    @property ref string material() { return _material; }
    override Bson serialize()
    {
        auto bson = this.defaultBson();
        bson["profile"] = Bson(_profile);
        bson["mountStyle"] = Bson(_mountStyle);
        bson["material"] = Bson(_material);
        return bson;
    }
private:
    string _profile;
    string _mountStyle;
    string _material;
}


unittest
{
    writeln("creating accessory object");
    auto keycaps = new KeyboardKeycap(["o-rings", "silent"],
                        PartIdentification(["wasdkeyboards"], "unknown", "0.2mm O-rings", [Configuration("color", ["red", "blue"])]),
                        [ProductLink("wadkeyboards.com", "I cant be bothered", 3.45)],
                        ["I really cant be bothered"], "# O-rings\nOrings are cool but also bad", 
                        1,
                        "SA", "Mx", "ABS");
}
