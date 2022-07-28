using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using HwTask = Languages.DbModels.Task;
using Task = System.Threading.Tasks.Task;

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
    public async Task<TeacherSummaryVm> Get()
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        List<Class> classes = await da.Classes.ForTeacher(teacher.TeacherId);
        ClassVm[] classVms = await Task.WhenAll(classes
            .Select(async cla => new ClassVm
            {
                Id = cla.ClassId,
                Name = cla.Name,
                NumActiveTasks = (await da.Tasks.ActiveForClass(cla.ClassId)).Count(),
                NumStudents = (await da.Enrollments.ForClass(cla.ClassId)).Count()
            })
            .ToList());

        List<HwTask> tasks = await da.Tasks.ForTeacher(teacher.TeacherId);
        List<Deck> decks = await da.Decks.ForTeacher(teacher.TeacherId);

        return new TeacherSummaryVm
        {
            Classes = classVms.ToList(),
            Tasks = tasks,
            Decks = decks
        };
    }
}