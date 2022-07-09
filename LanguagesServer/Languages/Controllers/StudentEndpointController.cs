using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authentication.MicrosoftAccount;

namespace Languages.Controllers;

[ApiController]
[Route("/student")]
public class StudentController: ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Authenticator auth;
    Shield shield;

    public StudentController(DatabaseContext db, DatabaseAccess da, Authenticator auth, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.auth = auth;
        this.shield = shield;
    }

    [HttpGet("test")]
    public string TestEndpoint()
    {
        Student student = shield.AuthenticateStudent(Request);

        return "Authenticated as " + student.FirstName + " " + student.Email;
    }

    [HttpGet("summary")]
    public object GetSummary(int studentId)
    {
        //return db.Students.ToList();

        // Get classes for student with studentId

        var qry = from enr in db.Enrollments
                  join cla in db.Classes on enr.ClassId equals cla.ClassId
                  where enr.StudentId == studentId
                  select new { cla.Name, cla.TeacherId, cla.ClassId };
        return qry.ToList();

    }

    [HttpGet("taskcards")]
    public List<TaskCardVm> GetTaskCards(int studentId)
    {
        var qry = from enr in db.Enrollments
                  where enr.StudentId == studentId
                  join task in db.Tasks on enr.ClassId equals task.TaskId
                  join card in db.Cards on task.DeckId equals card.DeckId
                  select new TaskCardVm
                  {
                      CardId = card.CardId,
                      EnglishTerm = card.EnglishTerm,
                      ForeignTerm = card.ForeignTerm,
                      DueDate = task.DueDate,
                      LastQuestionType = (
                          from stuAtt in db.StudentAttempts
                          where stuAtt.StudentId == studentId
                          where stuAtt.CardId == card.CardId
                          where stuAtt.Correct == true
                          orderby stuAtt.AttemptDate
                          select stuAtt.QuestionType
                      ).FirstOrDefault()
                  };

        return qry.ToList();
    }

    [HttpGet("reviewcards")]
    public string GetReviewCards()
    {
        return "Not yet implemented";
    }

    [HttpGet("taskdetails")]
    public Task GetTaskDetails(int taskId)
    {
        var qry = from task in db.Tasks
                  where task.TaskId == taskId
                  select task;
        return qry.FirstOrDefault();
    }

    [HttpPost("didAnswer")]
    public string PostDidAnswer()
    {
        return "Not yet implemented";
    }

    [HttpPost("joinClass")]
    public string PostJoinClass()
    {
        return "Not yet implemented";
    }
}