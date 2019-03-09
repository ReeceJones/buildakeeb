module backend.parts.part;


import vibe.data.bson;
import vibe.d;
import std.uuid: randomUUID;
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
struct KeyboardPart
{
    /// Part Tags
    string[]            tags;
    /// Information used to identify the part
    PartIdentification  partId;
    /// Links that contain additional information about an object, as well as pricing.
    ProductLink[]       productLinks;
    /// Links to images of a part.
    string[]            images;
    /// Description of the part in markdown format.
    string              description;
    /// Link to the part from the website. Used to navigate and search for parts internally.
    string              link;
    /// UUID of an object used to update it in case it's link changes.
    string              uuid;
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
    validateStruct!S;
    
    // insert the part
    auto client = connectMongoDB("127.0.0.1");
    auto dbInfo = extractDBProperties!S;
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);

    // check to make sure there are no existing entries
    if (collection.find!S.empty)
    {
        collection.insert(s);
    }
    else
    {
        throw new PartException("Cannot create part, part already exists.");
    }
}

/++
    Updates a struct in the database using its uuid.
Params:
    s - Refernce to s which will be updated.
+/
void update(S)(ref S s)
{
    auto client = connectMongoDB("127.0.0.1");
    auto dbInfo = extractDBProperties!S;
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);

    collection.update!(Bson, S)(Bson(["uuid": Bson(s.uuid)]), s);
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
    auto dbInfo = extractDBProperties!S;
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);
    
    return collection.findOne!S(Bson(["link": Bson(link)]));
}

/++
	Update an objects state by querying the database for an object using its uuid.
Params:
	s - Refernece to the struct that we are updating.
+/
void pull(S)(ref S s)
{
    auto client = connectMongoDB("127.0.0.1");
    auto db Info = extractDBProperties!S;
    auto collection = client.getCollection(dbInfo.dbs ~ "." ~ dbInfo.collection);

    string uuid  = s.uuid;

    s = collection.findOne!S(Bson(["uuid": Bson(uuid)]));
}

unittest
{
    import std.stdio: writeln;

    @db("build-a-keeb-parts-testing", "parts") struct TestPart
    {
        string[]            tags;
        PartIdentification  partId;
        ProductLink[]       productLinks;
        string[]            images;
        string              description;
        string              link;
        string              uuid;
    }
    TestPart tp = TestPart(["tag1", "tag2"], PartIdentification(["reece", "jones"], "ancestors", "human", 
                            cast(Configuration[])[]), cast(ProductLink[])[], ["https://reece.ooo"], "# hi", 
                            "Reece_Jones", "uuid");
    try {
        tp.insert();
    }
    catch (PartException pex) {
        writeln(pex.msg);
    }
    tp.tags = ["changed", "#noregerts"];
    tp.update;

    tp = pull!TestPart("Reece_Jones");
    assert(tp.tags == ["changed", "#noregerts"]);
}
