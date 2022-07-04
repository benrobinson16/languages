using Microsoft.AspNetCore.Mvc;
using Languages.Database;
using Languages.Models;
using Task = Languages.Models.Task;
using Microsoft.AspNetCore.Authorization;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher")]
[Authorize]
public class TeacherController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;

    public TeacherController(DatabaseContext db, DatabaseAccess da)
    {
        this.db = db;
        this.da = da;
    }

    /// <summary>
    /// Gets summary information for the logged in teacher's home screen.
    /// </summary>
    /// <param name="teacherId">The id of the teacher who is logged in.</param>
    /// <returns>A TeacherSummaryVm that provides home screen info.</returns>
    [HttpGet("summary")]
    public TeacherSummaryVm Summary(int teacherId)
    {
        var classQry = from cla in db.Classes
                       where cla.TeacherId == teacherId
                       select cla;
        var taskQry = from task in db.Tasks
                      join cla in db.Classes on task.ClassId equals cla.ClassId
                      where cla.TeacherId == teacherId
                      where task.DueDate > DateTime.Now.AddDays(-2.0)
                      orderby task.DueDate
                      select task;
        var teacherQry = from teacher in db.Teachers
                         where teacher.TeacherId == teacherId
                         select teacher;

        return new TeacherSummaryVm
        {
            Classes = classQry.ToList(),
            Tasks = taskQry.ToList(),
            Teacher = teacherQry.Single()
        };
    }

    [HttpGet("classsummary")]
    public void ClassSummary(int classId)
    {

    }

    /// <summary>
    /// Creates a new class.
    /// </summary>
    /// <param name="teacherId">The id of the teacher to whom the class belongs.</param>
    /// <param name="name">The name to give to the class.</param>
    /// <returns></returns>
    [HttpPost("newclass")]
    public int NewClass(int teacherId, string name)
    {
        string code;
        Random random = new Random();
        do
        {
            long num = random.NextInt64() % 1_0000_0000;
            long firstHalf = num / 1_0000;
            long secondHalf = num % 1_0000;
            code = Convert.ToString(firstHalf) + "-" + Convert.ToString(secondHalf);
        }
        while (db.Classes.Any(c => c.JoinCode == code));

        Class cla = new Class
        {
            TeacherId = teacherId,
            Name = name,
            JoinCode = code
        };

        db.SaveChanges();

        return cla.ClassId;
    }

    [HttpGet("decksummary")]
    public void DeckSummary(int deckId)
    {
        
    }

    /// <summary>
    /// Creates a new empty deck with the provided name.
    /// </summary>
    /// <param name="teacherId">The id of the teacher who should own the deck.</param>
    /// <param name="name">The name of the deck.</param>
    /// <returns>The id of the new deck, which can then be edited via EditDeck</returns>
    [HttpPost("newdeck")]
    public int NewDeck(int teacherId, string name)
    {
        Deck deck = new Deck
        {
            Name = name,
            TeacherId = teacherId
        };

        db.Decks.Add(deck);
        db.SaveChanges();

        return deck.DeckId;
    }

    /// <summary>
    /// Creates a new card in a deck.
    /// </summary>
    /// <param name="deckId">The deck to add this card to.</param>
    /// <param name="englishTerm">The English translation.</param>
    /// <param name="foreignTerm">The foreign language translation.</param>
    /// <returns>The id of the card for further editing.</returns>
    [HttpPost("newcard")]
    public int NewCard(int deckId, string englishTerm, string foreignTerm)
    {
        Card card = new Card
        {
            DeckId = deckId,
            EnglishTerm = englishTerm,
            ForeignTerm = foreignTerm,
            Difficulty = 0.5
        };

        db.Cards.Add(card);
        db.SaveChanges();

        return card.CardId;
    }

    /// <summary>
    /// Replaces the current content of a card with new content.
    /// </summary>
    /// <param name="cardId">The id of the card to edit.</param>
    /// <param name="englishTerm">The English translation.</param>
    /// <param name="foreignTerm">The foreign language translation.</param>
    /// <exception cref="Exception">An invalid cardId was provided.</exception>
    [HttpPost("editcard")]
    public void EditCard(int cardId, string englishTerm, string foreignTerm)
    {
        Card? card = db.Cards
            .Where(c => c.CardId == cardId)
            .FirstOrDefault();

        if (card == null) throw new Exception("invalid cardid");

        card.EnglishTerm = englishTerm;
        card.ForeignTerm = foreignTerm;

        db.SaveChanges();
    }

    /// <summary>
    /// Deletes a card from a deck.
    /// </summary>
    /// <param name="cardId">The id of the card to delete.</param>
    /// <exception cref="Exception">An invalid cardId was provided.</exception>
    [HttpPost("deletecard")]
    public void DeleteCard(int cardId)
    {
        Card? card = db.Cards
            .Where(c => c.CardId == cardId)
            .FirstOrDefault();

        if (card == null) throw new Exception("invalid cardid");

        db.Cards.Remove(card);
        db.SaveChanges();
    }

    [HttpGet("tasksummary")]
    public void TaskSummary(int taskId)
    {

    }

    /// <summary>
    /// Creates a new task and assigns it to a class for completion.
    /// </summary>
    /// <param name="classId">The id of the class to assign this to.</param>
    /// <param name="deckId">The deck to assign.</param>
    /// <param name="dueDate">The due date of the class.</param>
    /// <returns>The id of the new task.</returns>
    [HttpPost("newtask")]
    public int NewTask(int classId, int deckId, DateTime dueDate)
    {
        Task task = new Task
        {
            ClassId = classId,
            DeckId = deckId,
            DueDate = dueDate
        };

        db.Tasks.Add(task);
        db.SaveChanges();

        return task.TaskId;
    }

    /// <summary>
    /// Edits the deck and due date of a task.
    /// </summary>
    /// <param name="taskId">The task to edit.</param>
    /// <param name="deckId">The new deck to associate with this task.</param>
    /// <param name="dueDate">The new due date of this task.</param>
    /// <exception cref="Exception"></exception>
    [HttpPost("edittask")]
    public void EditTask(int taskId, int deckId, DateTime dueDate)
    {
        Task? task = db.Tasks
            .Where(t => t.TaskId == taskId)
            .FirstOrDefault();

        if (task == null) throw new Exception("invalid taskid");

        task.DeckId = deckId;
        task.DueDate = dueDate;

        db.SaveChanges();
    }
}