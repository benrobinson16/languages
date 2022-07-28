using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/account")]
public class AccountController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public AccountController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpPost("register/student")]
    public Student RegisterStudent()
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

        return student;
    }

    [HttpPost("register/teacher")]
    public Teacher RegisterTeacher(string title, string surname)
    {
        User user = shield.Authenticate(Request);

        bool existingTeacher = da.Teachers.ExistingForEmail(user.Email);
        if (existingTeacher) throw new LanguagesOperationAlreadyExecuted();

        Teacher teacher = new Teacher
        {
            Title = title,
            Surname = surname,
            Email = user.Email,
        };

        db.Teachers.Add(teacher);
        db.SaveChanges();

        return teacher;
    }

    [HttpGet("details/student")]
    public Student StudentDetails()
    {
        Student student = shield.AuthenticateStudent(Request);
        return student;
    }

    [HttpGet("details/teacher")]
    public Teacher TeacherDetails()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);
        return teacher;
    }
}