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

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        Class? cla = da.Classes.ById(task.ClassId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return task;
    }

    [HttpPost]
    public Task Post(int deckId, int classId, DateTime dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        Task task = new Task
        {
            ClassId = classId,
            DeckId = deckId,
            DueDate = dueDate
        };

        db.Tasks.Add(task);
        db.SaveChanges();

        return task;
    }

    [HttpPatch]
    public Task Patch(int taskId, int deckId, int classId, DateTime dueDate)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        Class? originalClass = da.Classes.ById(task.ClassId);
        if (originalClass == null) throw new LanguagesResourceNotFound();
        if (originalClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        if (classId != originalClass.ClassId)
        {
            Class? newClass = da.Classes.ById(classId);
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

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        Class? originalClass = da.Classes.ById(task.ClassId);
        if (originalClass == null) throw new LanguagesResourceNotFound();
        if (originalClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Tasks.Remove(task);
        db.SaveChanges();
    }
}