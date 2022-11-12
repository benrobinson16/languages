using JWT.Algorithms;
using JWT.Builder;
using System.Net;
using System.Security.Cryptography;

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
    private const string pathToKey = "/Constants/apns-key.p8";

    private string? providerToken = null;
    private DateTime lastGenerated = DateTime.UnixEpoch;

    private string GenerateAPNsToken()
    {
        string keyContents = File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory.ToString() + pathToKey);
        string cleanedContents = keyContents
            .Replace("-----BEGIN PRIVATE KEY-----", "")
            .Replace("-----END PRIVATE KEY-----", "");
        byte[] keyBytes = Convert.FromBase64String(cleanedContents);

        ECDsa key = ECDsa.Create();
        key.ImportPkcs8PrivateKey(keyBytes, out _);

        lastGenerated = DateTime.Now;
        return JwtBuilder.Create()
            .WithAlgorithm(new ES256Algorithm(key, key))
            .AddClaim("alg", "ES256")
            .AddClaim("iat", DateTimeOffset.UtcNow.ToUnixTimeSeconds())
            .AddClaim("kid", kid)
            .AddClaim("iss", iss)
            .Encode();
    }

    private void SendPayloadToApple(string deviceToken, string title, string body, string category)
    {
        if (providerToken == null || lastGenerated.AddMinutes(45) < DateTime.Now)
        {
            providerToken = GenerateAPNsToken();
        }

        HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, baseUrl + "/3/device/" + deviceToken);

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