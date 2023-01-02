using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/summary")]
public class SummaryController : ControllerBase
{
    DatabaseAccess da;
    Shield shield;

    public SummaryController(DatabaseAccess da, Shield shield)
    {
        this.da = da;
        this.shield = shield;
    }

    /// <summary>
    /// Gets a summary of all decks, tasks and classes associated with the current teacher.
    /// </summary>
    /// <returns>The summary object.</returns>
    [HttpGet]
    public TeacherSummaryVm Get()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        List<ClassVm> classes = da.Classes.VmsForTeacher(teacher.TeacherId).ToList();
        List<TaskVm> tasks = da.Tasks.VmsForTeacher(teacher.TeacherId).ToList();
        List<DeckVm> decks = da.Decks.VmsForTeacher(teacher.TeacherId).ToList();

        return new TeacherSummaryVm
        {
            Classes = classes,
            Tasks = tasks,
            Decks = decks
        };
    }
}