using System.Text.Json;
using GlobalExceptionHandler.WebApi;
using Languages.Services;
using Languages.ApiModels;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add API controllers.
builder.Services.AddControllers();

// Add service layer. Scoped to ensure no concurrent access to dbContext.
builder.Services.AddDbContext<DatabaseContext>();
builder.Services.AddScoped<DatabaseAccess>();
builder.Services.AddScoped<Shield>();

// This instance is created directly, because we want the certificates to be loaded
// in advance of the first request. Singleton is used because it does not depend
// on the dbContext so does not need to be scoped.
builder.Services.AddSingleton<Authenticator>(new Authenticator());

// Generate documentation site.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Allow OPTIONS pre-flight requests
app.UseCors((opt) =>
{
    opt.AllowCredentials();
    opt.AllowAnyHeader();
    opt.AllowAnyMethod();
    opt.WithOrigins("http://localhost:3000", "*");
});

app.UseGlobalExceptionHandler(opt => {
    opt.ResponseBody(s => JsonSerializer.Serialize(new
    {
        Message = "An error occurred."
    }));

    opt.Map<LanguagesUnauthorized>().ToStatusCode(StatusCodes.Status403Forbidden);
    opt.Map<LanguagesResourceNotFound>().ToStatusCode(StatusCodes.Status404NotFound);
    opt.Map<LanguagesUnauthenticated>().ToStatusCode(StatusCodes.Status401Unauthorized);
    opt.Map<LanguagesOperationAlreadyExecuted>().ToStatusCode(StatusCodes.Status409Conflict);
    opt.Map<LanguagesInternalError>().ToStatusCode(StatusCodes.Status500InternalServerError);
});

app.UseHttpsRedirection();
app.MapControllers();
app.Run();
