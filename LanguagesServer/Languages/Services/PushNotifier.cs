using JWT.Algorithms;
using JWT.Builder;
using System.Net;
using System.Security.Cryptography;
using RestSharp;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Net.Http.Headers;
using System.Dynamic;

namespace Languages.Services;

public class PushNotifier
{
    private DatabaseAccess da;

    public PushNotifier(DatabaseAccess da)
    {
        this.da = da;
    }

    public void SendCongrats(string teacherName, string deckName, int student)
    {
        SendNotification(
            "Congratulations",
            "Well done for your work on " + deckName + ". - " + teacherName,
            "CONGRATS",
            new List<int> { student }
        );
    }

    public void SendReminder(string teacherName, string deckName, DateTime dueDate, int student)
    {
        if (dueDate > DateTime.Now)
        {
            // Future
            string strDateDue = "on " + dueDate.ToShortDateString();
            if (dueDate.Date.AddDays(-1) == DateTime.Now.Date)
            {
                strDateDue = "tomorrow";
            }

            SendNotification(
                "Don't forget!",
                "Remember to do your homework on " + deckName + ". It is due " + strDateDue + "! - " + teacherName,
                "FUTURE_REMINDER",
                new List<int> { student }
            );
        }
        else
        {
            // Past
            string strDateDue = "on " + dueDate.ToShortDateString();
            if (dueDate.Date.AddDays(1) == DateTime.Now.Date)
            {
                strDateDue = "yesterday";
            }

            SendNotification(
                "Don't forget!",
                "Remember to do your homework on " + deckName + ". It was due " + strDateDue + "! - " + teacherName,
                "PAST_REMINDER",
                new List<int> { student }
            );
        }
    }

    public void SendNewTask(string className, string teacherName, string deckName, DateTime dueDate, List<int> students)
    {
        SendNotification(
            "New Task",
            teacherName + " has set a new task for " + className + ". Complete " + deckName + " by " + dueDate.ToShortDateString() + ".",
            "NEW_TASK",
            students
        );
    }

    private void SendNotification(string title, string body, string category, List<int> students)
    {
        List<string> tokens = students
            .Select(stu => da.Students.ForId(stu).SingleOrDefault())
            .Where(result => result != null)
            .Select(result => result!.DeviceToken)
            .Where(token => token != null)
            .Select(token => token!)
            .ToList();

        foreach (string t in tokens)
        {
            SendPayloadToApple(t, title, body, category);
        }
    }

    private const string kid = "6J3TF84B5K";
    private const string iss = "QARY953TUQ";
    private const string baseUrl = "https://api.sandbox.push.apple.com:443";
    private const string bundleId = "dev.benrobinson.LanguagesApp";
    private const string pathToKey = "/Constants/apns-key.p8";

    private string? providerToken = null;
    private DateTime lastGenerated = DateTime.UnixEpoch;

    private string GenerateAPNsToken()
    {
        string keyContents = File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory.ToString() + pathToKey);
        string cleanedContents = keyContents
            .Replace("-----BEGIN PRIVATE KEY-----", "")
            .Replace("-----END PRIVATE KEY-----", "")
            .Replace("\r", "");
            //.Replace("\n", "");
        byte[] keyBytes = Convert.FromBase64String(cleanedContents);

        ECDsa key = ECDsa.Create();
        key.ImportPkcs8PrivateKey(keyBytes, out _);

        lastGenerated = DateTime.Now;
        return JwtBuilder.Create()
            .WithAlgorithm(new ES256Algorithm(key, key))
            .AddClaim("iat", DateTimeOffset.UtcNow.ToUnixTimeSeconds())
            .AddClaim("iss", iss)
            .AddHeader("kid", kid)
            .Encode();
    }

    private async void SendPayloadToApple(string deviceToken, string title, string body, string category)
    {
        if (providerToken == null || lastGenerated.AddMinutes(45) < DateTime.Now)
        {
            providerToken = GenerateAPNsToken();
        }

        HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, baseUrl + "/3/device/" + deviceToken);
        request.Version = new Version(2, 0);
        request.Headers.Add("apns-topic", bundleId);
        request.Headers.Add("apns-push-type", "alert");
        request.Headers.Authorization = new AuthenticationHeaderValue("bearer", providerToken);

        dynamic payload = new ExpandoObject();
        payload.aps = new ExpandoObject();
        payload.aps.alert = new
        {
            title = title,
            body = body
        };

        request.Content = JsonContent.Create(payload);

        HttpClient client = new HttpClient();
        HttpResponseMessage response = await client.SendAsync(request);

        Console.WriteLine(JsonSerializer.Serialize(payload));
        Console.WriteLine(deviceToken);
        Console.WriteLine(response.StatusCode);
        Console.WriteLine(await response.Content.ReadAsStringAsync());

        if (response.StatusCode == HttpStatusCode.OK)
        {
            // Success
            Console.WriteLine("Success");
        }
        else
        {
            // Failure
            Console.WriteLine("FAILURE");
        }
    }
}