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
    /// Update the token associated with a student to facilitate push notifications.
    /// </summary>
    /// <param name="token">The device token for push notifications.</param>
    [HttpPost("registerdevice")]
    public StatusResponse RegisterDeviceToken(string token)
    {
        Student student = shield.AuthenticateStudent(Request);
        student.DeviceToken = token;
        db.SaveChanges();
        return new StatusResponse { Success = true };
    }

    /// <summary>
    /// Alerts the server that a student has logged out of a device and should
    /// therefore no longer receive push notifications on that device.
    /// </summary>
    [HttpPost("removedevice")]
    public StatusResponse RemoveRegisteredDevice()
    {
        Student student = shield.AuthenticateStudent(Request);
        student.DeviceToken = null;
        db.SaveChanges();
        return new StatusResponse { Success = true };
    }

    /// <summary>
    /// Checks if a teacher has already been registered using the OAUTH token.
    /// </summary>
    /// <returns>Whether the teacher is already registered.</returns>
    [HttpPost("teacher/isnew")]
    public bool IsNewTeacher()
    {
        User user = shield.Authenticate(Request);
        return da.Teachers.ForEmail(user.Email).Any();
    }

    /// <summary>
    /// Checks if a student has already been registered using the OAUTH token.
    /// Will create the student with the OAUTH data if doesn't already exist.
    /// </summary>
    /// <returns>Whether the student is a new student.</returns>
    [HttpPost("student/isnew")]
    public bool IsNewStudent()
    {
        User user = shield.Authenticate(Request);
        bool isNew = !da.Students.ForEmail(user.Email).Any();

        if (isNew)
        {
            Student student = new Student
            {
                FirstName = user.FirstName,
                Surname = user.Surname,
                Email = user.Email,
                DeviceToken = null
            };

            db.Students.Add(student);
            db.SaveChanges();
        }

        return isNew;
    }
}