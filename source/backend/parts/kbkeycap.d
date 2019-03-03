module backend.parts.kbkeycap;

import backend.parts.part;
import vibe.data.bson;

class KeyboardKeycap : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "plate");
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
