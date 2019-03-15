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
            return Tuple!(string, "dbs", string, "collection")(__traits(getMember, attributes[i], "dbs"), __traits(getMember, attributes[i], "collection"));
        }
    }
    return Tuple!(string, "dbs", string, "collection")("", "");
}



/// User defined attribute that is used to determine which members we want to take
enum field = "field";

/++
    Used to generate a struct from the members of a class. When making a class, all fields that you want to be placed in the struct, must be marked with the @field property.
+/
string toStruct(C)()
{
	// s is the string that will be the source Code of the struct;
    string s = "";
    static foreach(i, attr; __traits(getAttributes, C))
    {
        s = "@" ~ __traits(getAttributes, C)[i].stringof ~ " ";
    }
    
    s ~= "struct Struct {";
    enum members = __traits(allMembers, C);
    static foreach(i, member; members)
    {
        // check to make sure that they have the field attribute
        static if (member != "this" && member != "~this")
        {
            static foreach(attr; __traits(getAttributes, __traits(getMember, C, member)))
            {
                if (attr == "field")
                    s ~= typeof(__traits(getMember, C, member)).stringof ~ " " ~ member ~ ";";
            }
        }
    }
    return s ~ "}";
}


unittest
{
	import std.stdio: writeln;
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

    class Foo1
    {
        this()
        {
            s = "this called";
            i = 50;
        }
        int betternotshowup;
        @field string s;
        @field int i;
        mixin(toStruct!Foo1);
    }
    class Foo2 : Foo1
    {
        this()
        {
            super();
            j = 50;
        }
        @field int j;
        mixin(toStruct!Foo2);
    }
    foreach(member; __traits(allMembers, Foo2.Struct))
    {
        writeln(member);
    }
}
