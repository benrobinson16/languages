using System.Text.Json;
using GlobalExceptionHandler.WebApi;
using Languages.Services;
using Languages.Models;

var builder = WebApplication.CreateBuilder(args);

// Add student and teacher controllers.
builder.Services.AddControllers();

// Add a connection to the database.
DatabaseContext db = new DatabaseContext(builder.Configuration);
DatabaseAccess da = new DatabaseAccess(db);
Authenticator auth = new Authenticator();
Shield shield = new Shield(da, auth);

builder.Services.Add(new ServiceDescriptor(typeof(DatabaseContext), db));
builder.Services.Add(new ServiceDescriptor(typeof(DatabaseAccess), da));
builder.Services.Add(new ServiceDescriptor(typeof(Authenticator), auth));
builder.Services.Add(new ServiceDescriptor(typeof(Shield), shield));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
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
