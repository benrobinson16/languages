using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/class")]
public class ClassController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public ClassController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    /// <summary>
    /// Creates a summary of a class with all required dashboard information.
    /// </summary>
    /// <param name="classId">The id of the class to inspect.</param>
    /// <returns>The class summary.</returns>
    [HttpGet]
    public ClassSummaryVm Get(int classId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ForId(classId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        List<TaskVm> tasks = da.Tasks.VmsForClass(classId).ToList();
        List<string> students = da.Students.ForClass(classId).Select(stu => stu.DisplayName).ToList();

        ClassSummaryVm vm = new ClassSummaryVm
        {
            ClassDetails = new ClassVm
            {
                Id = cla.ClassId,
                Name = cla.Name,
                NumActiveTasks = tasks.Count(),
                NumStudents = students.Count(),
                JoinCode = cla.JoinCode
            },
            Tasks = tasks,
            Students = students
        };

        return vm;
    }

    /// <summary>
    /// Creates a new class.
    /// </summary>
    /// <param name="name">The name to provide to this new class.</param>
    /// <returns>The new class. Includes the id of the new class.</returns>
    [HttpPost]
    public ClassVm Post(string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        string code;
        Random random = new Random();

        do
        {
            long num = random.NextInt64() % 1_0000_0000;

            string firstHalf = Convert.ToString(num / 1_0000);
            while (firstHalf.Length < 4) firstHalf = "0" + firstHalf;

            string secondHalf = Convert.ToString(num % 1_0000);
            while (secondHalf.Length < 4) secondHalf = "0" + secondHalf;

            code = firstHalf + "-" + secondHalf;
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

    /// <summary>
    /// Edits a pre-existing class.
    /// </summary>
    /// <param name="classId">The id of the class to edit.</param>
    /// <param name="name">The new name of the class.</param>
    /// <returns>The updated class object.</returns>
    [HttpPatch]
    public ClassVm Patch(int classId, string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ForId(classId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        cla.Name = name;
        db.SaveChanges();

        return ConvertClassToVm(cla);
    }

    /// <summary>
    /// Deletes a class from the database.
    /// </summary>
    /// <param name="classId">The id of the class to delete.</param>
    [HttpDelete]
    public void Delete(int classId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ForId(classId).SingleOrDefault();
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        da.Tasks.RemoveForClass(cla.ClassId);
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