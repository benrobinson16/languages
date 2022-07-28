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
    public async Task<Student> RegisterStudent()
    {
        User user = shield.Authenticate(Request);

        bool existingStudent = await da.Students.ExistingForEmail(user.Email);
        if (existingStudent) throw new LanguagesOperationAlreadyExecuted();

        Student student = new Student
        {
            FirstName = user.FirstName,
            Surname = user.Surname,
            Email = user.Email,
        };

        db.Students.Add(student);
        await db.SaveChangesAsync();

        return student;
    }

    [HttpPost("register/teacher")]
    public async Task<Teacher> RegisterTeacher(string title, string surname)
    {
        User user = shield.Authenticate(Request);

        bool existingTeacher = await da.Teachers.ExistingForEmail(user.Email);
        if (existingTeacher) throw new LanguagesOperationAlreadyExecuted();

        Teacher teacher = new Teacher
        {
            Title = title,
            Surname = surname,
            Email = user.Email,
        };

        db.Teachers.Add(teacher);
        await db.SaveChangesAsync();

        return teacher;
    }

    [HttpGet("details/student")]
    public async Task<Student> StudentDetails()
    {
        Student student = await shield.AuthenticateStudent(Request);
        return student;
    }

    [HttpGet("details/teacher")]
    public async Task<Teacher> TeacherDetails()
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);
        return teacher;
    }
}