using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.ApiModels;
using Languages.DbModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/task")]
public class TeacherTaskController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherTaskController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet]
    public Task Get(int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Task? task = da.Tasks.ForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        Class? cla = da.Classes.ForId(task.ClassId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return task;
    }

    [HttpPost]
    public Task Post(int deckId, int classId, double dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ForId(classId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        // Convert from unix timestamp to C# DateTime.
        DateTime dueDateAsDate = DateTime.UnixEpoch.AddMilliseconds(dueDate);

        Task task = new Task
        {
            ClassId = classId,
            DeckId = deckId,
            DueDate = dueDateAsDate
        };

        db.Tasks.Add(task);
        db.SaveChanges();

        return task;
    }

    [HttpPatch]
    public Task Patch(int taskId, int deckId, int classId, DateTime dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Task? task = da.Tasks.ForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        Class? originalClass = da.Classes.ForId(task.ClassId).SingleOrDefault();
        if (originalClass == null) throw new LanguagesResourceNotFound();
        if (originalClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        if (classId != originalClass.ClassId)
        {
            Class? newClass = da.Classes.ForId(classId).SingleOrDefault();
            if (newClass == null) throw new LanguagesResourceNotFound();
            if (newClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

            task.ClassId = classId;
        }

        task.DeckId = deckId;
        task.DueDate = dueDate;
        db.SaveChanges();

        return task;
    }

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