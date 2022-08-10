using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/student")]
public class StudentController: ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public StudentController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet("summary")]
    public object GetSummary()
    {
        Student student = shield.AuthenticateStudent(Request);

        // TODO: Decide what is needed in the summary

        var qry = from enr in db.Enrollments
                  join cla in db.Classes on enr.ClassId equals cla.ClassId
                  where enr.StudentId == student.StudentId
                  select new { cla.Name, cla.TeacherId, cla.ClassId };

        return qry.ToList();
    }

    [HttpGet("taskcards")]
    public List<CardVm> GetTaskCards()
    {
        Student student = shield.AuthenticateStudent(Request);

        return da.Cards.TaskVmsForStudent(student.StudentId).ToList();
    }

    [HttpGet("reviewcards")]
    public string GetReviewCards()
    {
        return "Not yet implemented";
    }

    [HttpGet("taskdetails")]
    public Task GetTaskDetails(int taskId)
    {
        Student student = shield.AuthenticateStudent(Request);

        Task? task = da.Tasks.ForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        bool studentAssignedTask = da.Tasks.AssignedToStudent(taskId, student.StudentId);
        if (!studentAssignedTask) throw new LanguagesUnauthorized();

        return task;
    }

    [HttpPost("didAnswer")]
    public void PostDidAnswer(int cardId, bool correct, int questionType)
    {
        Student student = shield.AuthenticateStudent(Request);

        StudentAttempt attempt = new StudentAttempt
        {
            StudentId = student.StudentId,
            CardId = cardId,
            AttemptDate = DateTime.Now,
            Correct = correct,
            QuestionType = questionType
        };

        db.StudentAttempts.Add(attempt);
        db.SaveChanges();
    }

    [HttpPost("joinClass")]
    public void PostJoinClass(string joinCode)
    {
        Student student = shield.AuthenticateStudent(Request);

        var classQry = from cla in db.Classes
                       where cla.JoinCode == joinCode
                       select cla;

        Class? foundClass = classQry.FirstOrDefault();
        if (foundClass == null) throw new LanguagesResourceNotFound();

        var enrollmentQry = from enrol in db.Enrollments
                            where enrol.ClassId == foundClass.ClassId && enrol.StudentId == student.StudentId
                            select enrol;

        bool existingEnrollment = enrollmentQry.Any();
        if (existingEnrollment) throw new LanguagesOperationAlreadyExecuted();

        Enrollment newEnrollment = new Enrollment
        {
            ClassId = foundClass.ClassId,
            StudentId = student.StudentId
        };

        db.Enrollments.Add(newEnrollment);
        db.SaveChanges();
    }
}