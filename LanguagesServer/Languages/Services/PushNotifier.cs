using System;
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
                new List<int> { student }
            );
        }
    }

    public void SendNewTask(string className, string teacherName, string deckName, DateTime dueDate, List<int> students)
    {
        SendNotification(
            "New Task",
            teacherName + " has set a new task for " + className + ". Complete " + deckName + " by " + dueDate.ToShortDateString() + ".",
            students
        );
    }

    private void SendNotification(string title, string body, List<int> students)
    {

        // TODO: Send a notification to the device via Apple's servers
    }
}