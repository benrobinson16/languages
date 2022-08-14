using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/notification")]
public class NotificationController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;
    PushNotifier push;

    public NotificationController(DatabaseContext db, DatabaseAccess da, Shield shield, PushNotifier push)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
        this.push = push; 
    }

    /// <summary>
    /// Issues a reminder notification to a student.
    /// </summary>
    /// <param name="studentId">The id of the student to remind.</param>
    /// <param name="taskId">The task to remind them about.</param>
    [HttpPost("sendreminder/student")]
    public void SendReminder(int studentId, int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        (Task task, _, Deck deck) = TaskDetailsAndVerify(taskId, teacher.TeacherId);
        string? token = da.Students.ForId(studentId).SingleOrDefault()?.DeviceToken;
        if (token == null) throw new LanguagesResourceNotFound();

        push.SendReminder(teacher.DisplayName, deck.Name, task.DueDate, token);
    }

    /// <summary>
    /// Issues a celebratory notification to a student.
    /// </summary>
    /// <param name="studentId">The id of the student to congratulate.</param>
    /// <param name="taskId">The id of the task they succeeded at.</param>
    /// <exception cref="LanguagesResourceNotFound"></exception>
    [HttpPost("sendcongratulations")]
    public void SendCongratulations(int studentId, int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        (_, _, Deck deck) = TaskDetailsAndVerify(taskId, teacher.TeacherId);
        string? token = da.Students.ForId(studentId).SingleOrDefault()?.DeviceToken;
        if (token == null) throw new LanguagesResourceNotFound();

        push.SendCongrats(teacher.DisplayName, deck.Name, token);
    }

    // Helper method to extract Task, Class and Deck from taskId. Does not fall
    // under DatabaseAccess service because it is across objects, and also requires
    // ownership checks that can throw to fail the entire request.
    private (Task, Class, Deck) TaskDetailsAndVerify(int taskId, int teacherId)
    {
        Task? task = da.Tasks.ForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        Class? cla = da.Classes.ForId(task.ClassId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacherId) throw new LanguagesUnauthorized();

        Deck? deck = da.Decks.ForId(task.DeckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();

        return (task, cla, deck);
    }
}