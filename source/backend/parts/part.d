module backend.parts.part;


import vibe.data.bson;
import vibe.d;
import std.uuid: randomUUID;
import std.regex: regex, replaceAll;
import std.algorithm: map, fold;
import std.array: array;
import std.conv: text;

struct Configuration
{
    string field;
    string[] options;
}

struct PartIdentification
{
    string[]            vendors;        /// The people that sell the part.
    string              manufacturer;   /// Whoever manufactures the part
    string              name;           /// The actual name of the part
    Configuration[]    configurations; /// Map of configurations that exist for the part
}

struct ProductLink
{
    string website; /// Site name
    string url;     /// site url
    double price;   /// price here
}

class PartException : Exception
{
    ///
    this(string msg, string file = __FILE__, size_t line = __LINE__) 
    {
        super(msg, file, line);
    }
}

/++
    Parent class for various types of keyboard parts. Contains some DB helper functions, and 
+/
abstract class KeyboardPart
{
public:
    /// Create a keyboard part object with the database, and collection it is in
    this(string db, string collection)
    {
        _db = db;
        _collection = collection;
    }
    /// Create a keyboard part from a given link
    /// The part should already exist
    this(string db, string collection, string link, ref Bson result)
    {
        this(db, collection);

        MongoClient client = connectMongoDB("127.0.0.1");
        scope(exit) client.destroy;
        // get our collection
        MongoCollection col = client.getCollection(_db ~ "." ~ _collection);

        result = col.findOne(Bson(["link" : Bson(link)]));
        this.applyDefault(result);
    }
    /// Create a new keyboard part that doesn't already exist
    this(string db, string collection, string[] tags, PartIdentification partId, ProductLink[] productLinks, 
            string[] images, string description, uint amount)
    {
        // set database
        this(db, collection);
        // set fields
        _tags = tags;
        _partId = partId;
        _productLinks = productLinks;
        _images = images;
        _description = description;
        _amount = amount;
        _uuid = randomUUID().toString;

        // update internal link
        this.updateLink();
    }
    /++ 
        Child classes must override this method. It must return a BSON representation of any relevant fields.
        returns: Bson object.
    +/
    abstract Bson serialize();
    /++
        Called by child classes. Ensures that no object exists already before inserting.
    +/
    void insert()
    {
        import std.stdio: writeln;
        auto data = this.serialize();

        MongoClient client = connectMongoDB("127.0.0.1");
        scope(exit) client.destroy;
        // get our collection
        MongoCollection collection = client.getCollection(_db ~ "." ~ _collection);
        

        // find any existing documents with the same url
        auto r = collection.findOne(Bson([
            "link": data["link"]
        ]));

        // make sure we aren't inserting duplicate data
        if (r == Bson(null))
        {
            collection.insert(data);
        }
        else
        {
            throw new PartException("part already exists");
        }

    }
    /++
        Update the object in the database given the current state of the object.
    +/
    void update()
    {
        // serialize the fields into JSON
        auto data = this.serialize();
        
        MongoClient client = connectMongoDB("127.0.0.1");
        scope(exit) client.destroy;
        // get our collection
        MongoCollection collection = client.getCollection(_db ~ "." ~ _collection);
        
        // update
        collection.update(Bson(["uuid" : Bson(_uuid)]), data, UpdateFlags.upsert);
    }
    /++
        Query the database for information about this part. Fields are auto-updated to the values of the database.
    +/
    void pull(ref Bson bson)
    {
        MongoClient client = connectMongoDB("127.0.0.1");
        scope(exit) client.destroy;
        MongoCollection collection = client.getCollection(_db ~ "." ~ _collection);
        bson = collection.findOne(Bson(["link": Bson(_link)]));
        this.apply(bson);
    }
    @property ref string[] tags() { return _tags; }                         /// 
    @property ref PartIdentification partId() { return _partId; }           /// 
    @property ref ProductLink[] productLinks() { return _productLinks; }    /// 
    @property ref string[] images() { return _images; }                     /// 
    @property ref string description() { return _description; }             /// 
    @property ref uint amount() { return _amount; }
    /// NEVER REF THIS
    @property string uuid() { return _uuid; }
    /// Update internal link when the name changes
    void updateLink()
    {
        string link = _partId.manufacturer ~ "/" ~ _partId.name;
        link = link.replaceAll(regex("[ ]", "g"), "_"); // replace spaces with underscores
        link = link.replaceAll(regex("[^a-zA-Z0-9_/]", "g"), ""); // remove anything that isn't a character, digit, or underscore
        _link = link;
    }
    override string toString()
    {
        return baseString() ~ "\n}";
    }
protected:
    string[]            _tags;          /// Tags of the object
    PartIdentification  _partId;        /// Identification information about the object
    ProductLink[]       _productLinks;  /// Links to the part
    string[]            _images;        /// Links to images of the part
    string              _description;   /// Description of the part in markdown format
    uint                _amount;        /// The amount of this part...Used for builds
    string              _link;          /// Used to query database and be urls

    void apply(Bson bson) {}

    Bson defaultBson()
    {
        // all the stuff we can do easily
        pragma(msg, typeof(_tags.map!(a => Bson(a)).array).stringof);
        auto bson = Bson([
            "description": Bson(_description),
            "amount": Bson(_amount),
            "link": Bson(_link),
            "uuid": Bson(_uuid)
        ]);
        bson["tags"] = _tags.map!(a => Bson(a)).array;
        bson["images"] = _images.map!(a => Bson(a)).array;
        bson["partId"] = Bson([
            "manufacturer": Bson(_partId.manufacturer),
            "name": Bson(_partId.name),
            "vendors": Bson(_partId.vendors.map!(a => Bson(a)).array),
            "configurations": Bson(
                _partId.configurations.map!(conf => Bson([
                    "field": Bson(conf.field),
                    "options" : Bson(conf.options.map!(a => Bson(a)).array)
                ])).array)
        ]);

        bson["productLinks"] = Bson(
            _productLinks.map!(l => Bson([
                "website": Bson(l.website),
                "url": Bson(l.url),
                "price": Bson(l.price)
            ])).array
        );
        return bson;
    }
    void applyDefault(Bson bson)
    {
        // tags are easy
        auto tgs = bson["tags"];
        for (int i = 0; i < tgs.length; i++)
            _tags ~= cast(string)tgs[i];
        
        // partId not so much
        // find all the vendors
        auto ven = bson["partId"]["vendors"];
        string[] vendors;
        for (int i = 0; i < ven.length; i++)
            vendors ~= cast(string)ven[i];


        // find all the partId configurations
        auto conf = bson["partId"]["configurations"];
        Configuration[] configurations;
        for (int i = 0; i < conf.length; i++)
        {
            auto opts = conf[i]["options"];
            string[] options;
            for (int j = 0; j < opts.length; j++)
                options ~= cast(string)opts[i];
            configurations ~= Configuration(cast(string)conf[i]["field"], options);
        }
        
        // partId
        _partId = PartIdentification(
            vendors,
            cast(string)bson["partId"]["manufacturer"],
            cast(string)bson["partId"]["name"],
            configurations
        );
        
        // product links
        auto pls = bson["productLinks"];
        for (int i = 0; i < pls.length; i++)
            _productLinks ~= ProductLink(cast(string)pls[i]["website"], cast(string)pls[i]["url"], cast(double)pls[i]["price"]);
        
        // do images
        auto imgs = bson["images"];
        for (int i = 0; i < imgs.length; i++)
            _images ~= cast(string)imgs[i];

        // other static stuff
        _description = cast(string)bson["description"];
        _amount = cast(uint)cast(int)bson["amount"];
        _link = cast(string)bson["link"];

        _uuid = cast(string)bson["uuid"];
    }
    string baseString()
    {
        return `{
    "uuid": ` ~ _uuid ~ `
    "tags": ` ~ tags.text ~ `
    "partId": {
        "vendors": ` ~ _partId.vendors.text ~ `
        "manufacturer": ` ~ _partId.manufacturer ~ `
        "name": ` ~ _partId.name ~ `
        "configurations": ` ~ _partId.configurations.fold!((a,b) => a ~= " Configuration(" ~ b.field ~ ", " ~ b.options.text ~ "), ")("[")[0..$-2] ~ " ]" ~ `
    }
    "productLinks": [
` ~ _productLinks.fold!((a, b) => a ~= "\t\tProductLink(" ~ b.website ~ ", " ~ b.url ~ ", " ~ b.price.text ~ ")\n")("") ~`\t]
    "images": ` ~ _images.text ~ `
    "description": ` ~ _description ~ `
    "amount": ` ~ _amount.text ~ `
    "link": ` ~ _link;
    }
private:
    string _db, _collection; /// Database and collection
    string _uuid;            /// uuid generated when the part is first created. 
}
