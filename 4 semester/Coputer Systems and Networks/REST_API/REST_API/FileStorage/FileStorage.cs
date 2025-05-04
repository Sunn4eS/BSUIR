namespace REST_API.FileStorage;

public class FileStorage
{
    private readonly string _storagePath;

    public FileStorage(string storagePath)
    {
        _storagePath = storagePath;
    }

    public IResult Get(string? filepath)
    {
        try
        {
            string fullPath = Path.Combine(_storagePath, filepath ?? string.Empty);
            if (Directory.Exists(fullPath))
            {
                var files = Directory.GetFiles(fullPath).Select(Path.GetFileName).ToArray();
                var dirs = Directory.GetDirectories(fullPath).Select(Path.GetFileName).ToArray();
                return Results.Ok(new {files,dirs});
            }

            if (!File.Exists(fullPath))
            {
                return Results.NotFound();
            }
            
            return Results.File(fullPath, "application/octet-stream");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return Results.InternalServerError(new { message = e.Message });
        }   
    }

    public IResult Delete(string? filepath)
    {
        try
        {
            string fullPath = Path.Combine(_storagePath, filepath ?? string.Empty);
            if (Directory.Exists(fullPath))
            {
                Directory.Delete(fullPath, true);
                return Results.Ok(new {message = "Directory deleted successfully!"});
            }

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
                return Results.Ok(new {message = "File deleted successfully!"});
            }
            
            return Results.NotFound();
        }
        
        catch (Exception e)
        {
            Console.WriteLine(e);
            return Results.InternalServerError(new { message = e.Message });
        }
    }

    public async Task<IResult> Put(string filepath, HttpContext content)
    {
        try
        {
            string fullPath = Path.Combine(_storagePath, filepath);
            //
            
            if (content.Request.Headers.TryGetValue("X-Copy-From", out var origin))
            {
                string? sourcePath = Path.Combine(_storagePath, origin!);
            
                // если файл-источник не найден 
                if (!File.Exists(sourcePath))
                {
                    return Results.NotFound(new {message = "source file not found"});
                }
            
                // если файл-источник найден, то копируем
                File.Copy(sourcePath, fullPath, true);
                return Results.Ok(new {message = "File uploaded successfully"});
            }
            Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);
            using var stream = new FileStream(fullPath, FileMode.Create);
            await content.Request.Body.CopyToAsync(stream);
            return Results.Created($"/{_storagePath}/{filepath}", new { message = "File uploaded successfully!" });
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return Results.InternalServerError(new { message = e.Message });
        }
    }

    public IResult Head(HttpContext context, string? filepath)
    {
        string fullPath = Path.Combine(_storagePath, filepath ?? string.Empty);
        if (!File.Exists(fullPath))
        {
            return Results.NotFound();
        }
        var fileInfo = new FileInfo(fullPath);
        context.Response.Headers["Content-Length"] = fileInfo.Length.ToString();
        context.Response.Headers["Last-Modified"] = fileInfo.LastWriteTime.ToString("R");
        return Results.Ok(new {fileInfo});
    }
}