using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.ApiModels;
using Languages.DbModels;
using HwTask = Languages.DbModels.Task;
using Microsoft.EntityFrameworkCore;

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
    public async Task<HwTask> Get(int taskId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        HwTask? task = await da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        Class? cla = await da.Classes.ById(task.ClassId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return task;
    }

    [HttpPost]
    public async Task<HwTask> Post(int deckId, int classId, DateTime dueDate)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Class? cla = await da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        HwTask task = new HwTask
        {
            ClassId = classId,
            DeckId = deckId,
            DueDate = dueDate
        };

        db.Tasks.Add(task);
        await db.SaveChangesAsync();

        return task;
    }

    [HttpPatch]
    public async Task<HwTask> Patch(int taskId, int deckId, int classId, DateTime dueDate)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        HwTask? task = await da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        Class? originalClass = await da.Classes.ById(task.ClassId);
        if (originalClass == null) throw new LanguagesResourceNotFound();
        if (originalClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        if (classId != originalClass.ClassId)
        {
            Class? newClass = await da.Classes.ById(classId);
            if (newClass == null) throw new LanguagesResourceNotFound();
            if (newClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

            task.ClassId = classId;
        }

        task.DeckId = deckId;
        task.DueDate = dueDate;
        await db.SaveChangesAsync();

        return task;
    }

    [HttpDelete]
    public async void Delete(int taskId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        HwTask? task = await da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        Class? originalClass = await da.Classes.ById(task.ClassId);
        if (originalClass == null) throw new LanguagesResourceNotFound();
        if (originalClass.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Tasks.Remove(task);
        await db.SaveChangesAsync();
    }
}