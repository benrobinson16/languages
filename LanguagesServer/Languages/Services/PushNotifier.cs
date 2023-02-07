using JWT.Algorithms;
using JWT.Builder;
using System.Net;
using System.Security.Cryptography;
using System.Text.Json;
using System.Net.Http.Headers;
using System.Dynamic;
using Languages.DbModels;

namespace Languages.Services;

/// <summary>
/// Responsible for sending push notifications to APNs.
/// </summary>
public class PushNotifier
{
    private DatabaseAccess da;

    private const string kid = "6J3TF84B5K";
    private const string iss = "QARY953TUQ";
    private const string baseUrl = "https://api.sandbox.push.apple.com:443";
    private const string bundleId = "dev.benrobinson.LanguagesApp";
    private const string pathToKey = "/Constants/apns-key.p8";

    private string? providerToken = null;
    private DateTime lastGenerated = DateTime.UnixEpoch;

    public PushNotifier(DatabaseAccess da)
    {
        this.da = da;
    }

    /// <summary>
    /// Called by a scheduler. Send daily reminder notifications to
    /// students who should be sent one within 1 minute.
    /// </summary>
    public void SendDailyReminders()
    {
        List<Student> students = da.Students.ForDailyReminders().ToList();

        SendNotification(
            "Time to practice!",
            "Remember to do some vocabulary revision today.",
            students
        );
    }

    /// <summary>
    /// Sends a congratulations notification to a student.
    /// </summary>
    /// <param name="teacherName">The name of the teacher sending.</param>
    /// <param name="deckName">The name of the deck the work was on.</param>
    /// <param name="student">The student's id.</param>
    public void SendCongrats(string teacherName, string deckName, int student)
    {
        SendNotification(
            "Congratulations",
            "Well done for your work on " + deckName + ". - " + teacherName,
            new List<int> { student }
        );
    }

    /// <summary>
    /// Sends a reminder notification to a student.
    /// </summary>
    /// <param name="teacherName">The name of the teacher sending.</param>
    /// <param name="deckName">The name of the deck the task is on.</param>
    /// <param name="dueDate">The due date of the task.</param>
    /// <param name="student">The id of the student.</param>
    public void SendReminder(string teacherName, string deckName, DateTime dueDate, int student)
    {
        if (dueDate > DateTime.Now)
        {
            // Future
            string strDateDue = "on " + dueDate.ToString("dd/MM/yyyy");
            if (dueDate.Date.AddDays(-1) == DateTime.Now.Date)
            {
                strDateDue = "tomorrow";
            }

            SendNotification(
                "Don't forget!",
                "Remember to do your homework on " + deckName + ". It is due " + strDateDue + "! - " + teacherName,
                new List<int> { student }
            );
        }
        else
        {
            // Past
            string strDateDue = "on " + dueDate.ToString("dd/MM/yyyy");
            if (dueDate.Date.AddDays(1) == DateTime.Now.Date)
            {
                strDateDue = "yesterday";
            }

            SendNotification(
                "Don't forget!",
                "Remember to do your homework on " + deckName + ". It was due " + strDateDue + "! - " + teacherName,
                new List<int> { student }
            );
        }
    }

    /// <summary>
    /// Sends a "New Task" notification to students.
    /// </summary>
    /// <param name="className">The class the task is set for.</param>
    /// <param name="teacherName">The name of the sending teacher.</param>
    /// <param name="deckName">The deck the task is set on.</param>
    /// <param name="dueDate">The due date of the task.</param>
    /// <param name="students">A list of students to send to.</param>
    public void SendNewTask(string className, string teacherName, string deckName, DateTime dueDate, List<int> students)
    {
        SendNotification(
            "New Task",
            teacherName + " has set a new task for " + className + ". Complete " + deckName + " by " + dueDate.ToString("dd/MM/yyyy") + ".",
            students
        );
    }

    /// <summary>
    /// Informs students the due date of their task has changed.
    /// </summary>
    /// <param name="teacherName">The name of the sending teacher.</param>
    /// <param name="deckName">The name of the deck the task is on.</param>
    /// <param name="dueDate">The (new) due date of the task.</param>
    /// <param name="students">The students to send to.</param>
    public void SendTaskDueDateChange(string teacherName, string deckName, DateTime dueDate, List<int> students)
    {
        SendNotification(
            "Due Date Changed",
            teacherName + " has changed the due date for " + deckName + " to be " + dueDate.ToString("dd/MM/yyyy") + ".",
            students
        );
    }

    /// <summary>
    /// Sends a notification to a list of students.
    /// </summary>
    /// <param name="title">The title of the notification.</param>
    /// <param name="body">The body of the notification.</param>
    /// <param name="students">A list of students to send to.</param>
    private void SendNotification(string title, string body, List<int> students)
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
            SendPayloadToApple(t, title, body);
        }
    }

    /// <summary>
    /// Sends a notification to a list of students.
    /// </summary>
    /// <param name="title">The title of the notification.</param>
    /// <param name="body">The body of the notification.</param>
    /// <param name="students">A list of students to send to.</param>
    private void SendNotification(string title, string body, List<Student> students)
    {
        List<string> tokens = students
            .Select(result => result.DeviceToken)
            .Where(token => token != null)
            .Select(token => token!)
            .ToList();

        foreach (string t in tokens)
        {
            SendPayloadToApple(t, title, body);
        }
    }

    /// <summary>
    /// Creates an APNs authentication token to verify identity with Apple.
    /// </summary>
    /// <returns>A valid APNs token.</returns>
    private string GenerateAPNsToken()
    {
        string keyContents = File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory.ToString() + pathToKey);
        string cleanedContents = keyContents
            .Replace("-----BEGIN PRIVATE KEY-----", "")
            .Replace("-----END PRIVATE KEY-----", "")
            .Replace("\r", "");
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

    /// <summary>
    /// Sends an APNs token to Apple.
    /// </summary>
    /// <param name="deviceToken">The token of the device to send to.</param>
    /// <param name="title">The notification title.</param>
    /// <param name="body">The notification body.</param>
    private async void SendPayloadToApple(string deviceToken, string title, string body)
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

        if (response.StatusCode != HttpStatusCode.OK)
        {
            // Failure
            Console.WriteLine("Failure sending APNs request. Aborting.");
        }
    }
}