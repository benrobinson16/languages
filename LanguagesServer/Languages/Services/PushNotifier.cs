using System;
namespace Languages.Services;

public class PushNotifier
{
    public PushNotifier() { }

    public void SendCongrats(string teacherName, string deckName, string deviceToken)
    {
        SendNotification(
            "Congratulations",
            "Well done for your work on " + deckName + ". - " + teacherName,
            new List<string> { deviceToken }
        );
    }

    public void SendReminder(string teacherName, string deckName, DateTime dueDate, string deviceToken)
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
                new List<string> { deviceToken }
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
                new List<string> { deviceToken }
            );
        }
    }

    public void SendNewTask(string className, string teacherName, string deckName, DateTime dueDate, List<string> deviceTokens)
    {
        SendNotification(
            "New Task",
            teacherName + " has set a new task for " + className + ". Complete " + deckName + " by " + dueDate.ToShortDateString() + ".",
            deviceTokens
        );
    }

    private void SendNotification(string title, string body, List<string> deviceTokens)
    {
        // TODO: Send a notification to the device via Apple's servers
    }
}