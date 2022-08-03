using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/class")]
public class TeacherClassController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherClassController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet]
    public ClassSummaryVm? Get(int classId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        List<Task> tasks = da.Tasks.ForClass(classId);
        List<string> students = da.Students.ForClass(classId).Select(stu => stu.DisplayName).ToList();

        ClassSummaryVm vm = new ClassSummaryVm
        {
            ClassDetails = new ClassVm
            {
                Id = cla.ClassId,
                Name = cla.Name,
                NumActiveTasks = tasks.Where(t => t.DueDate > DateTime.Now).Count(),
                NumStudents = students.Count(),
                JoinCode = cla.JoinCode
            },
            Tasks = tasks,
            Students = students
        };

        return vm;
    }

    [HttpPost]
    public ClassVm Post(string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        string code;
        Random random = new Random();

        do
        {
            long num = random.NextInt64() % 1_0000_0000;
            long firstHalf = num / 1_0000;
            long secondHalf = num % 1_0000;
            code = Convert.ToString(firstHalf) + "-" + Convert.ToString(secondHalf);
        }
        while (da.Classes.JoinCodeExists(code));

        Class cla = new Class
        {
            TeacherId = teacher.TeacherId,
            Name = name,
            JoinCode = code
        };

        db.Classes.Add(cla);
        db.SaveChanges();

        return ConvertClassToVm(cla);
    }

    [HttpPatch]
    public ClassVm Patch(int classId, string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        cla.Name = name;
        db.SaveChanges();

        return ConvertClassToVm(cla);
    }

    [HttpDelete]
    public void Delete(int classId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Classes.Remove(cla);
        db.SaveChanges();
    }

    private ClassVm ConvertClassToVm(Class cla)
    {
        return new ClassVm
        {
            Id = cla.ClassId,
            Name = cla.Name,
            NumActiveTasks = da.Tasks.ActiveForClass(cla.ClassId).Count(),
            NumStudents = da.Enrollments.ForClass(cla.ClassId).Count(),
            JoinCode = cla.JoinCode
        };
    }
}