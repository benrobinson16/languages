using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;

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

    [HttpGet]
    public Class? Get(int classId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return cla;
    }

    [HttpPost]
    public Class Post(string name)
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

        return cla;
    }

    [HttpPatch]
    public Class Patch(int classId, string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? cla = da.Classes.ById(classId);
        if (cla == null) throw new LanguagesResourceNotFound();
        if (cla.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        cla.Name = name;
        db.SaveChanges();

        return cla;
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
}