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

    /// <summary>
    /// Register a new student with an account.
    /// </summary>
    /// <returns>The new student object (with id).</returns>
    [HttpPost("student/register")]
    public Student RegisterStudent()
    {
        User user = shield.Authenticate(Request);

        bool existingStudent = da.Students.ForEmail(user.Email).Any();
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

    /// <summary>
    /// Register a new teacher.
    /// </summary>
    /// <param name="title">The title of the teacher.</param>
    /// <param name="surname">The surname of the teacher.</param>
    /// <returns>The new teacher object (with id).</returns>
    [HttpPost("teacher/register")]
    public Teacher RegisterTeacher(string title, string surname)
    {
        User user = shield.Authenticate(Request);

        bool existingTeacher = da.Teachers.ForEmail(user.Email).Any();
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

    /// <summary>
    /// Gets the details associated with a student by decoding the JWT.
    /// </summary>
    /// <returns>The student object.</returns>
    [HttpGet("student/details")]
    public Student StudentDetails()
    {
        Student student = shield.AuthenticateStudent(Request);
        return student;
    }

    /// <summary>
    /// Gets the details associated with a teacher by decoding the JWT.
    /// </summary>
    /// <returns>The teacher object.</returns>
    [HttpGet("teacher/details")]
    public Teacher TeacherDetails()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);
        return teacher;
    }

    /// <summary>
    /// Update the token associated with a student to facilitate push notifications.
    /// </summary>
    /// <param name="token">The device token for push notifications.</param>
    [HttpPost("student/devicetoken")]
    public void PostDeviceToken(string token)
    {
        Student student = shield.AuthenticateStudent(Request);
        student.DeviceToken = token;
        db.SaveChanges();
    }

    /// <summary>
    /// Alerts the server that a student has logged out of a device and should
    /// therefore no longer receive push notifications on that device.
    /// </summary>
    [HttpPost("student/devicelogout")]
    public void PostDeviceLogout()
    {
        Student student = shield.AuthenticateStudent(Request);
        student.DeviceToken = null;
        db.SaveChanges();
    }
}