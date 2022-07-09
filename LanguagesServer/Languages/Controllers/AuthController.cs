using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/student")]
public class AuthController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public AuthController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpPost("test")]
    public string Test()
    {
        User user = shield.Authenticate(Request);
        return user.Email;
    }

    [HttpPost("testStudent")]
    public string TestStudent()
    {
        Student student = shield.AuthenticateStudent(Request);
        return student.Email;
    }

    [HttpPost("testTeacher")]
    public string TestTeacher()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);
        return teacher.Email;
    }

    [HttpPost("registerStudent")]
    public void RegisterStudent()
    {
        User user = shield.Authenticate(Request);

        bool existingStudent = da.Students.ExistingForEmail(user.Email);
        if (existingStudent) throw new LanguagesOperationAlreadyExecuted();

        Student student = new Student
        {
            FirstName = user.FirstName,
            Surname = user.Surname,
            Email = user.Email,
        };

        db.Students.Add(student);
        db.SaveChanges();
    }

    [HttpPost("registerTeacher")]
    public void RegisterTeacher(string title)
    {
        User user = shield.Authenticate(Request);

        bool existingTeacher = da.Teachers.ExistingForEmail(user.Email);
        if (existingTeacher) throw new LanguagesOperationAlreadyExecuted();

        Teacher teacher = new Teacher
        {
            Title = title,
            Surname = user.Surname,
            Email = user.Email,
        };

        db.Teachers.Add(teacher);
        db.SaveChanges();
    }
}