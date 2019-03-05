module backend.parts.part;


import vibe.data.bson;
import vibe.d;
import std.uuid: randomUUID;
import std.regex: regex, replaceAll;
import std.algorithm: map, fold;
import std.array: array;
import std.conv: text;

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


