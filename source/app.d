import std.stdio;
import vibe.d;
import backend.parts;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", staticTemplate!"index.dt");

	auto settings = new HTTPServerSettings;
	settings.port = 9001;
	settings.bindAddresses = ["::1", "0.0.0.0"];
    settings.sessionStore = new MemorySessionStore;
	
    listenHTTP(settings, router);
}

