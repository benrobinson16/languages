using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;

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
    public List<TaskCardVm> GetTaskCards()
    {
        Student student = shield.AuthenticateStudent(Request);

        var qry = from enr in db.Enrollments
                  where enr.StudentId == student.StudentId
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
                          where stuAtt.StudentId == student.StudentId
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
        Student student = shield.AuthenticateStudent(Request);

        Task? task = da.Tasks.ById(taskId);
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