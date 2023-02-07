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
    private DatabaseContext db;
    private DatabaseAccess da;
    private Shield shield;
    private MemoryModel mm;

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
            .Where(t => t.DueDate < DateTime.Now)
            .Where(t => !da.StudentAttempts.HasCompletedTask(student.StudentId, t.DeckId, t.SetDate))
            .ToList();

        List<TaskVm> upcoming = taskVms
            .Where(t => t.DueDate >= DateTime.Now)
            .ToList();

        List<TaskVm> taskList = incompleteOverdue
            .Union(upcoming)
            .OrderBy(t => t.DueDate)
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
            Tasks = taskList,
            Enrollments = da.Enrollments.VmsForStudent(student.StudentId).ToList(),
            DailyPercentage = da.StudentAttempts.DailyCompletion(student.StudentId),
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

    [HttpGet("modelcard")]
    public double ModelCard(int cardId)
    {
        Student student = shield.AuthenticateStudent(Request);
        Card card = da.Cards.ForId(cardId).Single();
        return mm.ModelCard(card, student.StudentId);
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
        task.Completion = (double)da.StudentAttempts.StudentProgress(deck, student.StudentId, task.SetDate) / 100.0;

        return new StudentTaskSummaryVm
        {
            TaskDetails = task,
            Cards = deck
        };
    }

    [HttpPost("didAnswer")]
    public StatusResponse PostDidAnswer(int cardId, bool correct, int questionType)
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

        return new StatusResponse { Success = true };
    }

    [HttpPost("joinClass")]
    public StatusResponse JoinClass(string joinCode)
    {
        Student student = shield.AuthenticateStudent(Request);

        var classQry = from cla in db.Classes
                       where cla.JoinCode == joinCode
                       select cla;

        Class? foundClass = classQry.FirstOrDefault();
        if (foundClass == null) {
            return new StatusResponse
            {
                Message = "Class does not exist. Please check your join code.",
                Success = false
            };
        }

        var enrollmentQry = from enrol in db.Enrollments
                            where enrol.ClassId == foundClass.ClassId && enrol.StudentId == student.StudentId
                            select enrol;

        bool existingEnrollment = enrollmentQry.Any();
        if (existingEnrollment) return new StatusResponse
        {
            Message = "You are already enrolled in this class.",
            Success = false
        };

        Enrollment newEnrollment = new Enrollment
        {
            ClassId = foundClass.ClassId,
            StudentId = student.StudentId,
            JoinDate = DateTime.Now
        };

        db.Enrollments.Add(newEnrollment);
        db.SaveChanges();

        return new StatusResponse {
            Message = "You have succesfully been added to class " + foundClass.Name + ".",
            Success = true
        };
    }

    [HttpPost("leaveClass")]
    public StatusResponse LeaveClass(int classId)
    {
        Student student = shield.AuthenticateStudent(Request);

        Enrollment? enrollment = da.Enrollments.ForId(classId, student.StudentId).FirstOrDefault();
        if (enrollment == null)
        {
            return new StatusResponse
            {
                Success = false,
                Message = "You are not enrolled in that class."
            };
        }

        db.Remove(enrollment);
        db.SaveChanges();

        return new StatusResponse
        {
            Message = null,
            Success = true
        };
    }

    [HttpGet("distractors")]
    public List<string> GetDistractors(int cardId)
    {
        Student student = shield.AuthenticateStudent(Request);

        Card? targetCard = da.Cards.ForId(cardId).SingleOrDefault();
        if (targetCard == null) throw new LanguagesResourceNotFound();

        List<Card> siblingCards = da.Cards.SiblingsForCard(cardId).ToList();
        List<Card> selectedCards = new List<Card>();
        Random random = new Random();

        while (selectedCards.Count() < 3 && siblingCards.Count() >= 1)
        {
            int index = random.Next() % siblingCards.Count();
            Card selectedCard = siblingCards[index];

            if (selectedCard.EnglishTerm != targetCard.EnglishTerm && selectedCard.ForeignTerm != targetCard.ForeignTerm)
            {
                selectedCards.Add(selectedCard);
            }

            siblingCards.RemoveAt(index);
        }

        while (selectedCards.Count() < 3)
        {
            Card newCard = da.Cards.RandomCard();

            if (selectedCards.Any(c => c.CardId == newCard.CardId)) continue;

            if (newCard.EnglishTerm != targetCard.EnglishTerm && newCard.ForeignTerm != targetCard.ForeignTerm)
            {
                selectedCards.Add(newCard);
            }
        }

        while (selectedCards.Count() < 3)
        {
            selectedCards.Add(new Card
            {
                CardId = -1,
                EnglishTerm = "ERROR!",
                ForeignTerm = "ERROR!"
            });
        }

        return selectedCards.Select(c => c.ForeignTerm).ToList();
    }

    [HttpGet("dailyCompletion")]
    public double GetDailyCompletion()
    {
        Student student = shield.AuthenticateStudent(Request);
        return da.StudentAttempts.DailyCompletion(student.StudentId);
    }

    [HttpGet("settingsSummary")]
    public SettingsSummary GetSettingsSummary()
    {
        Student student = shield.AuthenticateStudent(Request);

        return new SettingsSummary
        {
            Name = student.DisplayName,
            Email = student.Email,
            DailyReminderEnabled = student.DailyReminderEnabled,
            ReminderTime = student.ReminderTime
        };
    }

    [HttpPatch("updateNotificationSettings")]
    public StatusResponse UpdateNotificationSettings(DateTime time, bool enabled)
    {
        Student student = shield.AuthenticateStudent(Request);

        student.ReminderTime = time;
        student.DailyReminderEnabled = enabled;

        db.SaveChanges();

        return new StatusResponse { Success = true };
    }
}