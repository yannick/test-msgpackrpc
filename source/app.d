import vibe.d;
import msgpackrpc.client;
import vibe.core.connectionpool;

ConnectionPool!TCPClient client;
static this(){
 client = new ConnectionPool!TCPClient( { return new TCPClient(Endpoint(5000, "127.0.0.1")); } );
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{

  runTask({
    //crashes on the 2nd call with:
    //Task terminated with unhandled exception: Acquiring reader of already owned connection.
    auto c = client.lockConnection();
    auto num = c.call!string("echo", "echo");
    import std.stdio;
    writeln(num);
  });
	res.writeBody("Hello, World!");
}


void main()
{
	// returns false if a help screen has been requested and displayed (--help)
	if (!finalizeCommandLineOptions())
		return;
  auto router = new URLRouter;
  router.get("/", &hello);

  router.get("*", serveStaticFiles("public"));

  auto settings = new HTTPServerSettings;
  settings.port = 9099;
  settings.bindAddresses = ["0.0.0.0"];
  settings.options = settings.options 
      | HTTPServerOption.parseCookies

      | HTTPServerOption.parseQueryString;
  
  
  //settings.options = settings.options       | HTTPServerOption.distribute  ;
  listenHTTP(settings, router);
  
  lowerPrivileges();
  runEventLoop();
}