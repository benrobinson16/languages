using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/summary")]
public class SummaryController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public SummaryController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet]
    public TeacherSummaryVm Get()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        List<Class> classes = da.Classes.ForTeacher(teacher.TeacherId);
        List<Task> tasks = da.Tasks.ForTeacher(teacher.TeacherId);
        List<Deck> decks = da.Decks.ForTeacher(teacher.TeacherId);

        return new TeacherSummaryVm
        {
            Classes = classes,
            Tasks = tasks,
            Decks = decks
        };
    }
}