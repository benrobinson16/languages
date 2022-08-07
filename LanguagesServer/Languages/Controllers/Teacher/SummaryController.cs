using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/summary")]
public class TeacherSummaryController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherSummaryController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet]
    public TeacherSummaryVm Get()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        List<ClassVm> classVms = da.Classes
            .ForTeacher(teacher.TeacherId)
            .Select(cla => new ClassVm
            {
                Id = cla.ClassId,
                Name = cla.Name,
                NumActiveTasks = da.Tasks.ActiveForClass(cla.ClassId).Count(),
                NumStudents = da.Enrollments.ForClass(cla.ClassId).Count()
            })
            .ToList();

        List<TaskVm> tasks = da.Tasks.VmsForTeacher(teacher.TeacherId).ToList();
        List<Deck> decks = da.Decks.ForTeacher(teacher.TeacherId).ToList();

        Console.WriteLine(decks);

        return new TeacherSummaryVm
        {
            Classes = classVms.ToList(),
            Tasks = tasks,
            Decks = decks
        };
    }
}