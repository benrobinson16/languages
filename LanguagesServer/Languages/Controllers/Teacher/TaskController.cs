using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.ApiModels;
using Languages.DbModels;
using Task = Languages.DbModels.Task;
using System.Linq;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/task")]
public class TaskController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;
    PushNotifier push;

    public TaskController(DatabaseContext db, DatabaseAccess da, Shield shield, PushNotifier push)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
        this.push = push;
    }

    /// <summary>
    /// Gets a summary of a task.
    /// </summary>
    /// <param name="taskId">The id of the task to inspect.</param>
    /// <returns>The summary object.</returns>
    [HttpGet]
    public TeacherTaskSummaryVm Get(int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);
        if (!da.Tasks.OwnedByTeacher(taskId, teacher.TeacherId)) throw new LanguagesUnauthorized();

        TaskVm? task = da.Tasks.VmForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        List<StudentProgress> students = da.StudentAttempts
            .ProgressForTask(task.DeckId, task.ClassId, task.SetDate)
            .ToList();

        return new TeacherTaskSummaryVm
        {
            TaskDetails = task,
            Students = students
        };
    }

    /// <summary>
    /// Creates a new task.
    /// </summary>
    /// <param name="deckId">The id of the deck to assign.</param>
    /// <param name="classId">The id of the class to assign the deck to.</param>
    /// <param name="dueDate">The due date of the task in milliseconds since Unix Epoch.</param>
    /// <returns>The newly created task (including id).</returns>
    [HttpPost]
    public TaskVm Post(int deckId, int classId, double dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ForId(classId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        Deck? deck = da.Decks.ForId(deckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();

        // Convert from unix timestamp to C# DateTime.
        DateTime dueDateAsDate = DateTime.UnixEpoch.AddMilliseconds(dueDate);

        Task task = new Task
        {
            ClassId = classId,
            DeckId = deckId,
            DueDate = dueDateAsDate,
            SetDate = DateTime.Now
        };

        db.Tasks.Add(task);
        db.SaveChanges();

        List<int> students = da.Enrollments.ForClass(classId).Select(e => e.StudentId).ToList();
        push.SendNewTask(cla.Name, teacher.DisplayName, deck.Name, dueDateAsDate, students);

        return new TaskVm
        {
            Id = task.TaskId,
            ClassId = classId,
            ClassName = cla.Name,
            DeckId = deckId,
            DeckName = deck.Name,
            DueDate = task.DueDate,
            SetDate = task.SetDate
        };
    }

    /// <summary>
    /// Edits a pre-existing task.
    /// </summary>
    /// <param name="taskId">The id of the task to edit.</param>
    /// <param name="deckId">The new id of the task's deck.</param>
    /// <param name="classId">The new id of the task's class.</param>
    /// <param name="dueDate">The new due date of the task in milliseconds since the Unix Epoch.</param>
    /// <returns>The edited task.</returns>
    [HttpPatch]
    public TaskVm Patch(int taskId, int? deckId, int? classId, double? dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Task? task = da.Tasks.ForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        Class? cla = da.Classes.ForId(task.ClassId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        Deck? deck = da.Decks.ForId(task.DeckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();

        if (classId != cla.ClassId && classId != null)
        {
            Class? newClass = da.Classes.ForId(classId.Value).SingleOrDefault();
            if (newClass == null) throw new LanguagesResourceNotFound();
            if (newClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

            task.ClassId = classId.Value;
            cla = newClass;
        }

        if (deckId != null && deckId != task.DeckId)
        {
            Deck? newDeck = da.Decks.ForId(deckId.Value).SingleOrDefault();
            if (newDeck == null) throw new LanguagesResourceNotFound();

            task.DeckId = deckId.Value;
            deck = newDeck;
        }

        bool dueDateDidChange = false;
        if (dueDate != null)
        {
            // Convert from unix timestamp to C# DateTime.
            DateTime dueDateAsDate = DateTime.UnixEpoch.AddMilliseconds(dueDate.Value);

            dueDateDidChange = dueDateAsDate != task.DueDate;
            task.DueDate = dueDateAsDate;
        }

        db.SaveChanges();

        if (dueDateDidChange)
        {
            List<int> studentIds = da.Enrollments.ForClass(task.ClassId).Select(e => e.StudentId).ToList();
            push.SendTaskDueDateChange(teacher.DisplayName, deck.Name, task.DueDate, studentIds);
        }

        return new TaskVm
        {
            Id = task.TaskId,
            ClassId = cla.ClassId,
            ClassName = cla.Name,
            DeckId = deck.DeckId,
            DeckName = deck.Name,
            DueDate = task.DueDate,
            SetDate = task.SetDate
        };
    }

    /// <summary>
    /// Deletes a task from the database.
    /// </summary>
    /// <param name="taskId">The id of the task to delete.</param>
    [HttpDelete]
    public void Delete(int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Task? task = da.Tasks.ForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        Class? originalClass = da.Classes.ForId(task.ClassId).SingleOrDefault();
        if (originalClass == null) throw new LanguagesResourceNotFound();
        if (originalClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Tasks.Remove(task);
        db.SaveChanges();
    }
}