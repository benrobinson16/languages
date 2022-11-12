using System;
using System.Security.Cryptography.X509Certificates;
using JWT;
using JWT.Algorithms;
using JWT.Serializers;
using JWT.Builder;
using Newtonsoft.Json.Linq;
using System.Net;

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

    private const string kid = "QARY953TUQ";
    private const string iss = "6J3TF84B5K";
    private const string baseUrl = "https://api.sandbox.push.apple.com:443";
    private const string bundleId = "dev.benrobinson.LanguagesApp";
    private const string pathToKey = "/constants/apns-key.p8";

    private string? providerToken = null;
    private DateTime lastGenerated = DateTime.UnixEpoch;

    private void GenerateAPNsToken()
    {
        string keyContents = File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory.ToString() + pathToKey);
        byte[] rawCertificate = Convert.FromBase64String(keyContents);
        X509Certificate2 cert = new X509Certificate2(rawCertificate);

        lastGenerated = DateTime.Now;
        providerToken = JwtBuilder.Create()
            .WithAlgorithm(new ES256Algorithm(cert))
            .AddClaim("alg", "ES256")
            .AddClaim("iss", DateTimeOffset.UtcNow.ToUnixTimeSeconds())
            .AddClaim("kid", kid)
            .AddClaim("iss", iss)
            .Encode();
    }

    private void SendPayloadToApple(string deviceToken, string title, string body, string category)
    {
        if (providerToken == null || lastGenerated.AddMinutes(45) < DateTime.Now)
        {
            GenerateAPNsToken();
        }

        HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, baseUrl);

        request.Headers.Add(":path", "/3/device/" + deviceToken);
        request.Headers.Add("authorization", "bearer " + providerToken);
        request.Headers.Add("apns-push-type", "alert");
        request.Headers.Add("apns-topic", bundleId);

        var payload = new
        {
            Aps = new
            {
                Alert = new
                {
                    Title = title,
                    Body = body
                },
                Category = category
            }
        };
        request.Content = JsonContent.Create(payload);

        HttpClient client = new HttpClient();
        HttpResponseMessage response = client.Send(request);

        if (response.StatusCode == HttpStatusCode.OK)
        {
            // Success
            Console.WriteLine("Success");
        }
        else
        {
            // Failure
            Console.WriteLine("FAILURE");
            Console.WriteLine(response.StatusCode);
            Console.WriteLine(response.Content.ToString());
        }
    }
}