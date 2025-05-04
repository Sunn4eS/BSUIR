using REST_API.FileStorage;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions()
{
    WebRootPath = "storage"
});
var app = builder.Build();
Directory.CreateDirectory("storage");
string strpath = Path.Combine(Directory.GetCurrentDirectory(), "storage");
FileStorage storage = new FileStorage(strpath);

app.MapGet("/{**path}",(string? path) => storage.Get(path));
app.MapPut("/{**path}", async (string path, HttpContext context) => await storage.Put(path, context));
app.MapDelete("/{**path}", (string? path) => storage.Delete(path));
app.MapMethods("/{**path}", new [] {"HEAD"}, (HttpContext context, string path) => storage.Head(context, path));

app.Run();