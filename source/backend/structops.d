module backend.structops;

import std.typecons: tuple, Tuple;
import backend.parts;

/++
    Reads members of a POD struct, and returns code that allows the mixin of that struct.
Params:
    S - Struct to inherit.
Returns:
    string that must be mixed in to inherhit the fields of S.
+/
string inherit(S)() if (__traits(isPOD, S))
{
    string mix;
    foreach(mem; __traits(allMembers, S))
    {
        auto a = "";
        enum attributes = __traits(getAttributes, __traits(getMember, S, mem));
        foreach(i, s; attributes)
        {
            a ~= "@" ~ attributes[i].stringof ~ " ";
        }
        mix ~= a ~ typeof(__traits(getMember, S, mem)).stringof ~ " " ~ mem ~ ";";
    }
    return mix;
}

/++
    Checks if the given struct has the database attribute.
Params:
    S - The struct to check;
Returns:
    Boolean indicating whether or not the given struct contains the database attribute.
+/
bool hasDBAttr(S)()
{
    enum attributes = __traits(getAttributes, S);
    static foreach(i, attr; attributes)
    {
        if (typeof(__traits(getAttributes, S)[i]).stringof == "db") return true;
    }
    return false;
}

/++
    Validates that a given part struct is valid. If a part is not valid it static asserts.
+/
void validateStruct(S)()
{
    static if (!hasDBAttr!S)
        static assert(0, "missing @db attribute");
}

/++
    Extracts elements of a db attribute
Params:
    S - The struct to read.
Returns:
    Tuple containing database and collection information.
+/
Tuple!(string, "dbs", string, "collection") extractDBProperties(S)()
{
    enum attributes = __traits(getAttributes, S);
    foreach(i, attr; attributes)
    {
        if (typeof(__traits(getAttributes, S)[i]).stringof == "db")
        {
            pragma(msg, attributes[i].stringof);
            return Tuple!(string, "dbs", string, "collection")(__traits(getMember, attributes[i], "dbs"), __traits(getMember, attributes[i], "collection"));
        }
    }
    return Tuple!(string, "dbs", string, "collection")("", "");
}

unittest
{
    struct foo
    {
        string s;
    }
    struct Foo
    {
        @foo("bar") int a;
        int b;
    }
    pragma(msg, inherit!Foo);
    struct Bar
    {
        mixin(inherit!Foo);
        string c;
    }
    pragma(msg, __traits(allMembers, Bar));
    assert(__traits(allMembers, Bar) == tuple("a", "b", "c"));
    assert(__traits(getAttributes, __traits(getMember, Bar, "a")).stringof == "tuple(foo(\"bar\"))");
}
