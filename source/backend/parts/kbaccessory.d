module backend.parts.kbaccessory;

import backend.parts.part;
import vibe.data.bson;
import std.stdio;
import std.range;

class KeyboardAccessory : KeyboardPart
{
public:
    this()
    {
        super("build-a-keeb-parts", "accessories");
    }
    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount, string category, string[string] specifications)
    {
        super("build-a-keeb-parts", "accessories", tags, partId, productLinks, images, description, amount);
        _category = category;
        _specifications = specifications;

        try {
            this.insert();
        } catch(PartException pex) {
            writeln("could not insert part: ", pex.msg);
        }
    }
    this(string link)
    {
        Bson result;
        super("build-a-keeb-parts", "accessories", link, result);
    }
    @property ref string category() { return _category; }
    @property ref string[string] specifications() { return _specifications; }

    override Bson serialize()
    {
        auto bson = this.defaultBson();
        bson["category"] = Bson(_category);
        bson["specifications"] = Bson.emptyObject;
        foreach(key, val; specifications.byPair)
        {
            bson["specifications"][key] = Bson(val);
        }
        return bson;
    }
private:
    string _category;
    string[string] _specifications;
}

