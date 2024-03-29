using System.Text.Json;
using GlobalExceptionHandler.WebApi;
using Languages.Services;
using Languages.ApiModels;
using Microsoft.AspNetCore.HttpOverrides;
using FluentScheduler;

var builder = WebApplication.CreateBuilder(args);

// Add API controllers.
builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new DateConverter());
    });

// Add service layer. Scoped to ensure no concurrent access to dbContext.
builder.Services.AddDbContext<DatabaseContext>();
builder.Services.AddScoped<DatabaseAccess>();
builder.Services.AddScoped<Shield>();
builder.Services.AddScoped<MemoryModel>();
builder.Services.AddScoped<PushNotifier>();

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
    opt.WithOrigins(
        "https://languages.benrobinson.dev",
        "https://api.sandbox.push.apple.com"
    );
});

// Error handling
app.UseGlobalExceptionHandler(opt => {
    opt.ResponseBody(s => JsonSerializer.Serialize(new
    {
        Message = "An error occurred."
    }));

    opt.Map<LanguagesUnauthorized>().ToStatusCode(StatusCodes.Status403Forbidden);
    opt.Map<LanguagesResourceNotFound>().ToStatusCode(StatusCodes.Status404NotFound);
    opt.Map<LanguagesUnauthenticated>().ToStatusCode(StatusCodes.Status401Unauthorized);
    opt.Map<LanguagesOperationAlreadyExecuted>().ToStatusCode(StatusCodes.Status412PreconditionFailed);
    opt.Map<LanguagesOperationNotCompleted>().ToStatusCode(StatusCodes.Status412PreconditionFailed);
    opt.Map<LanguagesInternalError>().ToStatusCode(StatusCodes.Status500InternalServerError);
});

// Use headers from the Apache proxy server.
app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
});

JobManager.Initialize();

// Run the push notification service every minute.
JobManager.AddJob(
    () => {
        // Get the PushNotifier from the service environment.
        PushNotifier? push = app.Services.CreateScope()
            .ServiceProvider
            .GetService(typeof(PushNotifier)) as PushNotifier;

        if (push != null)
        {
            Console.WriteLine("Running daily notifications.");
            push.SendDailyReminders();
        }
        else
        {
            Console.WriteLine("Failed to run daily notifications.");
        }
    },
    s => s.ToRunEvery(1).Minutes()
);

JobManager.Start();

// Start the app after connection the controllers.
app.MapControllers();
app.Run();
