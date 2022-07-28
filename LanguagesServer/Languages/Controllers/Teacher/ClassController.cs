using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;

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
    public async Task<ClassVm?> Get(int classId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Class? cla = await da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return await ConvertClassToVm(cla);
    }

    [HttpPost]
    public async Task<ClassVm> Post(string name)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        string code;
        Random random = new Random();

        do
        {
            long num = random.NextInt64() % 1_0000_0000;
            long firstHalf = num / 1_0000;
            long secondHalf = num % 1_0000;
            code = Convert.ToString(firstHalf) + "-" + Convert.ToString(secondHalf);
        }
        while (await da.Classes.JoinCodeExists(code));

        Class cla = new Class
        {
            TeacherId = teacher.TeacherId,
            Name = name,
            JoinCode = code
        };

        db.Classes.Add(cla);
        await db.SaveChangesAsync();

        return await ConvertClassToVm(cla);
    }

    [HttpPatch]
    public async Task<ClassVm> Patch(int classId, string name)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Class? cla = await da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        cla.Name = name;
        await db.SaveChangesAsync();

        return await ConvertClassToVm(cla);
    }

    [HttpDelete]
    public async void Delete(int classId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Class? cla = await da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Classes.Remove(cla);
        await db.SaveChangesAsync();
    }

    private async Task<ClassVm> ConvertClassToVm(Class cla)
    {
        return new ClassVm
        {
            Id = cla.ClassId,
            Name = cla.Name,
            NumActiveTasks = (await da.Tasks.ActiveForClass(cla.ClassId)).Count(),
            NumStudents = (await da.Enrollments.ForClass(cla.ClassId)).Count()
        };
    }
}