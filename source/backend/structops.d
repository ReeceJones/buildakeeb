module backend.structops;

import std.typecons: tuple;

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
