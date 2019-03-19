module backend.parts.part;


import vibe.data.bson;
import vibe.d;
import std.regex: regex, replaceAll;
import std.array: array;

import backend.structops;

/// A list of possible configurations for a part
struct Configuration
{
    string      field; /// The specific configuration parameter name
    string[]    options; /// list of possible configurations for this parameter
}

/// Basic Part Identification information
struct PartIdentification
{
    string[]            vendors;        /// The people that sell the part.
    string              manufacturer;   /// Whoever manufactures the part
    string              name;           /// The actual name of the part
    Configuration[]     configurations; /// Map of configurations that exist for the part
}

/// Link information
struct ProductLink
{
    string website; /// Site name
    string url;     /// site url
    double price;   /// price here
}

/// Basic exception class used to throw exceptions when working with parts.
class PartException : Exception
{
    ///
    this(string msg, string file = __FILE__, size_t line = __LINE__) 
    {
        super(msg, file, line);
    }
}

/// Property that located where a part is located in the database
@property struct db
{
    string dbs;         /// The database
    string collection;  /// The collection within the database
}

/++
    Structure that represents a base KeyboardPart Object. Child structs should expand on this using the inherit function from backend.structops.
+/
class KeyboardPart
{
public:
    /// Default constructor
    this(string[] tags, PartIdentification partId, ProductLink[] productLinks, string[] images, string description,
            string link, string uuid)
    {
        this.tags = tags;
        this.partId = partId;
        this.productLinks = productLinks;
        this.images = images;
        this.description = description;
        this.link = link;
        this.uuid = uuid;
    }

    /// Default constructor
    this()
    {

    }

    /// construct using our Struct
    this(S)(S s)
    {
        // make sure that we don't have anything we might not want
        static assert(__traits(isPOD, S), "Invalid struct: Struct either has non-field elements, or is not a KeyboardPart.Struct"); 

        // set all elements
        static foreach(i, member; __traits(allMembers, S))
        {
            mixin("this." ~ member ~ " = s." ~ member ~ ";");
        }
    }

    /// Part Tags
    @field string[]            tags;
    /// Information used to identify the part
    @field PartIdentification  partId;
    /// Links that contain additional information about an object, as well as pricing.
    @field ProductLink[]       productLinks;
    /// Links to images of a part.
    @field string[]            images;
    /// Description of the part in markdown format.
    @field string              description;
    /// Link to the part from the website. Used to navigate and search for parts internally.
    @field string              link;
    /// UUID of an object used to update it in case it's link changes.
    @field string              uuid;

    // generate struct used for querying database
    mixin(toStruct!KeyboardPart);
}


/// Fill a S.Struct using the fields of S
S.Struct serialize(S)(S c)
{
    S.Struct s;
    static foreach(member; __traits(allMembers, S.Struct))
    {
        mixin("s." ~ member ~ " = c." ~ member ~ ";");
    }
    return s;
}

/// Fill a S using the fields of S.Struct
S deserialize(S)(S.Struct s)
{
    S c = new S;
    static foreach(member; __traits(allMembers, S.Struct))
    {
        mixin("c." ~ member ~ " = s." ~ member ~ ";");
    }
    return c;
}

/++
    Insert a part into the database if it doesn't already exist.
Params:
    s - The part to insert.
Throws:
    PartException if the part already exists
+/
void insert(S)(S s)
{
    // check to make sure this is a valid struct
    validateStruct!(S.Struct);
    
    // insert the part
    auto client = connectMongoDB("127.0.0.1");
    auto dbInfo = extractDBProperties!(S.Struct);
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);

    // check to make sure there are no existing entries
    if (collection.findOne(Bson(["link": Bson(s.link)])).empty)
        collection.insert!(S.Struct)(s.serialize);
    else
        throw new PartException("Cannot create part, part already exists.");
}

/++
    Updates a struct in the database using its uuid.
Params:
    s - Refernce to s which will be updated.
+/
void update(S)(ref S s)
{
    // update the link so that it is formatted correctly
    //s.link = s.name.replaceAll(regex("[ ]", "g"), "_").replaceAll(regex("[^a-zA-z0-9_]", "g"), "");
	s.link = s.partId.name.replaceAll(regex("[ ]", "g"), "_").replaceAll(regex("[^a-zA-z0-9_]", "g"), "");
    if (s.link.length > 120)
        throw new PartException("Link length too long. Please shorten the name.");
    


    auto client = connectMongoDB("127.0.0.1");
    auto dbInfo = extractDBProperties!(S.Struct);
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);

    auto r = collection.findOne!(S.Struct)(Bson(["link": Bson(s.link)]));
    if (r == cast(S.Struct)0 || r.uuid == s.uuid) // This uuid already owns the link or the link isn't taken
        collection.update!(Bson, S.Struct)(Bson(["uuid": Bson(s.uuid)]), s.serialize);
    else
        throw new PartException("Cannot update part, part link already exists.");
}

/++
    Retrives an object from the database using struct S, and the given link.
Params:
    S - The struct that we want to return.
    link - The link that we use to query the database.
Returns:
    Struct that contains the information retrieved from the database.
+/
S find(S)(string link)
{
    auto client = connectMongoDB("127.0.0.1");
    auto dbInfo = extractDBProperties!(S.Struct);
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);
    
    return (cast(S.Struct)collection.findOne!(S.Struct)(Bson(["link": Bson(link)]))).deserialize!S;
}

// /++
// 	Update an objects state by querying the database for an object using its uuid.
// Params:
// 	s - Refernece to the struct that we are updating.
// +/
// void pull(S)(ref S s)
// {
//     auto client = connectMongoDB("127.0.0.1");
//     auto dbInfo = extractDBProperties!S;
//     auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);

//     string uuid  = s.uuid;

//     s = collection.findOne!(S)(Bson(["uuid": Bson(uuid)]));
// }

// for preventing scoping issues
version(unittest)
{
    @db("build-a-keeb-parts-testing", "parts") class TestPart : KeyboardPart 
    {
        this(string[] tags, PartIdentification partId, ProductLink[] productLinks, string[] images, string description,
            string link, string uuid, int age)
        {
            super(tags, partId, productLinks, images, description, link, uuid);
            this.age = age;
        }
        this() {} // required for deserialization
        @field int age;
        mixin(toStruct!TestPart);
    }
}

unittest
{
    import std.stdio: writeln;


    pragma(msg, __traits(getAttributes, TestPart)[0]);
    TestPart tp = new TestPart(["tag1", "tag2"], PartIdentification(["reece", "jones"], "ancestors", "Reece Jones", 
                            cast(Configuration[])[]), cast(ProductLink[])[], ["https://reece.ooo"], "# hi", 
                            "Reece_Jones", "uuid", 10);
    writeln(tp.serialize!TestPart);
    try {
        tp.insert();
    }
    catch (PartException pex) {
        writeln(pex.msg);
    }
    tp.tags = ["changed", "#noregerts"];
    tp.update!TestPart;
    assert(tp.link == "Reece_Jones");
    auto q = find!(TestPart)(tp.link);
    assert(q.tags == ["changed", "#noregerts"]);
}
