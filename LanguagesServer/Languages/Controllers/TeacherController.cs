using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher")]
public class TeacherController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }


    [HttpGet("tasksummary")]
    public void TaskSummary(int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsTask = da.Tasks.OwnedByTeacher(taskId, teacher.TeacherId);
        if (!ownsTask) throw new LanguagesUnauthorized();

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        // TODO: Build summary
    }

    /// <summary>
    /// Creates a new task and assigns it to a class for completion.
    /// </summary>
    /// <param name="classId">The id of the class to assign this to.</param>
    /// <param name="deckId">The deck to assign.</param>
    /// <param name="dueDate">The due date of the class.</param>
    /// <returns>The id of the new task.</returns>
    [HttpPost("newtask")]
    public int NewTask(int classId, int deckId, DateTime dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsClass = da.Classes.OwnedByTeacher(classId, teacher.TeacherId);
        if (!ownsClass) throw new LanguagesUnauthorized();

        Task task = new Task
        {
            ClassId = classId,
            DeckId = deckId,
            DueDate = dueDate
        };

        db.Tasks.Add(task);
        db.SaveChanges();

        return task.TaskId;
    }

    /// <summary>
    /// Edits the deck and due date of a task.
    /// </summary>
    /// <param name="taskId">The task to edit.</param>
    /// <param name="deckId">The new deck to associate with this task.</param>
    /// <param name="dueDate">The new due date of this task.</param>
    /// <exception cref="Exception"></exception>
    [HttpPost("edittask")]
    public void EditTask(int taskId, int deckId, DateTime dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsTask = da.Tasks.OwnedByTeacher(taskId, teacher.TeacherId);
        if (!ownsTask) throw new LanguagesUnauthorized();

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        task.DeckId = deckId;
        task.DueDate = dueDate;

        db.SaveChanges();
    }
}