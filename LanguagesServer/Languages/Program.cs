using System.Text;
using Languages.Database;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authentication.MicrosoftAccount;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add student and teacher controllers.
builder.Services.AddControllers();

// Add a connection to the database.
builder.Services.Add(new ServiceDescriptor(typeof(DatabaseContext), new DatabaseContext(builder.Configuration)));
builder.Services.Add(new ServiceDescriptor(typeof(DatabaseAccess), new DatabaseAccess()));

// Add authentication
//builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
//    .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, opt => builder.Configuration.Bind("JwtSettings", opt))
//    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, opt => builder.Configuration.Bind("CookieSettings", opt));

builder.Services
    .AddAuthentication((opt) =>
    {
        opt.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        opt.DefaultChallengeScheme = MicrosoftAccountDefaults.AuthenticationScheme;
    })
    .AddCookie()
    .AddMicrosoftAccount((opt) =>
    {
        opt.ClientId = "67d7b840-45a6-480b-be53-3d93c187ed66";
        opt.ClientSecret = "1al8Q~wnkh-frkb4Yhi3E.eNXPiEFZQQCw-PXaB6";
    });

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
    opt.WithOrigins("http://localhost:3000");
});

app.UseAuthentication();
app.UseAuthorization();

app.UseHttpsRedirection();
app.MapControllers();
app.Run();
