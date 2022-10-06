using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;
using System.Linq;

namespace Languages.Controllers;

[ApiController]
[Route("/student")]
public class StudentController: ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;
    MemoryModel mm;

    public StudentController(DatabaseContext db, DatabaseAccess da, Shield shield, MemoryModel mm)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
        this.mm = mm;
    }

    [HttpGet("summary")]
    public StudentSummaryVm Summary()
    {
        Student student = shield.AuthenticateStudent(Request);

        List<TaskVm> taskVms = da.Tasks.VmsForStudent(student.StudentId).ToList();

        List<TaskVm> incompleteOverdue = taskVms
            .Where(t => DateTime.Parse(t.DueDate) < DateTime.Now)
            .Where(t => !da.StudentAttempts.HasCompletedTask(student.StudentId, t.DeckId))
            .ToList();

        string message = "";
        if (incompleteOverdue.Count() == 1)
        {
            TaskVm taskVm = incompleteOverdue.Single();
            message = taskVm.DeckName + " for " + taskVm.ClassName + " is overdue. Start now to complete it.";
        }
        else if (incompleteOverdue.Count() > 1)
        {
            message = "You have " + incompleteOverdue.Count() + " tasks overdue. Start now to complete them.";
        }

        return new StudentSummaryVm
        {
            StreakHistory = da.StudentAttempts.StreakHistoryForStudent(student.StudentId),
            StreakLength = da.StudentAttempts.StreakLengthForStudent(student.StudentId),
            Tasks = taskVms,
            DailyPercentage = 100.0, // FIXME: NEED TO IMPLEMENT SCHEDULING ALGORITHM
            OverdueMessage = message,
            StudentName = student.FirstName
        };
    }

    [HttpGet("taskcards")]
    public List<CardVm> TaskCards()
    {
        Student student = shield.AuthenticateStudent(Request);
        return da.Cards.TaskVmsForStudent(student.StudentId).ToList();
    }

    [HttpGet("reviewcards")]
    public List<CardVm> ReviewCards()
    {
        Student student = shield.AuthenticateStudent(Request);
        return mm.NextCardsToReview(student.StudentId);
    }

    [HttpGet("taskdetails")]
    public StudentTaskSummaryVm TaskDetails(int taskId)
    {
        Student student = shield.AuthenticateStudent(Request);

        TaskVm? task = da.Tasks.VmForId(taskId).SingleOrDefault();
        if (task == null) throw new LanguagesResourceNotFound();

        bool studentAssignedTask = da.Tasks.AssignedToStudent(taskId, student.StudentId);
        if (!studentAssignedTask) throw new LanguagesUnauthorized();

        List<Card> deck = da.Cards.ForDeck(task.DeckId).ToList();

        return new StudentTaskSummaryVm
        {
            TaskDetails = task,
            Cards = deck
        };
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

        da.Cards.UpdateDifficulty(cardId);
    }

    [HttpPost("joinClass")]
    public void JoinClass(string joinCode)
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