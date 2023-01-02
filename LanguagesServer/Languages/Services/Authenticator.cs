using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;
using JWT;
using JWT.Algorithms;
using JWT.Serializers;
using Languages.ApiModels;

namespace Languages.Services;

public class Authenticator
{
    private readonly string keyEndpoint = "https://login.microsoftonline.com/common/discovery/keys";
    private readonly string audience = "67d7b840-45a6-480b-be53-3d93c187ed66";
    private readonly string issuerDomain = "https://login.microsoftonline.com/";

    private Dictionary<string, X509Certificate2> certificates;
    private DateTime nextRefresh;

    public Authenticator()
    {
        certificates = new Dictionary<string, X509Certificate2>();
        nextRefresh = DateTime.Now;

        RefreshPublicKeys();
    }

    public User? Authenticate(string bearerToken)
    {
        if (bearerToken == null || bearerToken == "") return null;

        IJsonSerializer serializer = new JsonNetSerializer();
        IDateTimeProvider provider = new UtcDateTimeProvider();
        IJwtValidator validator = new JwtValidator(serializer, provider);
        IBase64UrlEncoder urlEncoder = new JwtBase64UrlEncoder();

        IJwtDecoder headerDecoder = new JwtDecoder(serializer, urlEncoder);
        JwtHeader header = headerDecoder.DecodeHeader<JwtHeader>(bearerToken);

        User? user = null;

        try
        {
            X509Certificate2 cert = certificates[header.Kid];
            IJwtAlgorithm algorithm = new RS256Algorithm(cert);
            IJwtDecoder validatedDecoder = new JwtDecoder(serializer, validator, urlEncoder, algorithm);
            BearerToken decodedToken = validatedDecoder.DecodeToObject<BearerToken>(bearerToken);

            bool audValid = decodedToken.aud == audience;
            bool issValid = decodedToken.iss.StartsWith(issuerDomain);

            if (audValid && issValid)
            {
                user = new User
                {
                    FirstName = decodedToken.given_name,
                    Surname = decodedToken.family_name,
                    Email = decodedToken.email.ToLower()
                };
            }
        }
        catch
        {
            Console.WriteLine("Error decoding/validating token. User is null.");
        }

        // Check the keys before the next request
        if (DateTime.Now >= nextRefresh)
        {
            RefreshPublicKeys();
        }

        return user;
    }

    private async void RefreshPublicKeys()
    {
        HttpClient client = new HttpClient();

        // Accept JSON result
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github.v3+json"));

        string stringResult = await client.GetStringAsync(keyEndpoint);
        Response result = new JsonNetSerializer().Deserialize<Response>(stringResult);

        Dictionary<string, X509Certificate2> newCerts = new();
        foreach (JsonWebKey key in result.keys)
        {
            byte[] rawCertificate = Convert.FromBase64String(key.x5c[0]);
            X509Certificate2 cert = new X509Certificate2(rawCertificate);
            newCerts[key.kid] = cert;
        }

        certificates = newCerts;
        nextRefresh = DateTime.Now.AddMinutes(30);
    }

    private class Response
    {
        public List<JsonWebKey> keys;
    }

    private class JsonWebKey
    {
        public string kid;
        public string[] x5c;
    }

    private class BearerToken
    {
        public string aud;
        public string iss;
        public string family_name;
        public string given_name;
        public string email;
    }
}