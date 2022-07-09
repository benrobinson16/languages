using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher")]
public class TeacherController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    /// <summary>
    /// Gets summary information for the logged in teacher's home screen.
    /// </summary>
    /// <param name="teacherId">The id of the teacher who is logged in.</param>
    /// <returns>A TeacherSummaryVm that provides home screen info.</returns>
    [HttpGet("summary")]
    public TeacherSummaryVm Summary()
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        List<Class> classes = da.Classes.ForTeacher(teacher.TeacherId);
        List<Task> tasks = da.Tasks.ForTeacher(teacher.TeacherId);

        return new TeacherSummaryVm
        {
            Classes = classes,
            Tasks = tasks,
            Teacher = teacher
        };
    }

    [HttpGet("classsummary")]
    public void ClassSummary(int classId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Class? foundClass = da.Classes.ById(classId);
        if (foundClass == null) throw new LanguagesResourceNotFound();

        bool ownsClass = foundClass.TeacherId == teacher.TeacherId;
        if (!ownsClass) throw new LanguagesUnauthorized();

        // TODO: Build class summary...
    }

    /// <summary>
    /// Creates a new class.
    /// </summary>
    /// <param name="teacherId">The id of the teacher to whom the class belongs.</param>
    /// <param name="name">The name to give to the class.</param>
    /// <returns></returns>
    [HttpPost("newclass")]
    public int NewClass(string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        string code;
        Random random = new Random();

        do
        {
            long num = random.NextInt64() % 1_0000_0000;
            long firstHalf = num / 1_0000;
            long secondHalf = num % 1_0000;
            code = Convert.ToString(firstHalf) + "-" + Convert.ToString(secondHalf);
        }
        while (da.Classes.JoinCodeExists(code));

        Class cla = new Class
        {
            TeacherId = teacher.TeacherId,
            Name = name,
            JoinCode = code
        };

        db.SaveChanges();

        return cla.ClassId;
    }

    [HttpGet("decksummary")]
    public void DeckSummary(int deckId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();

        bool ownsDeck = deck.TeacherId == teacher.TeacherId;
        if (!ownsDeck) throw new LanguagesUnauthorized();

        // TODO: Build deck summary
    }

    /// <summary>
    /// Creates a new empty deck with the provided name.
    /// </summary>
    /// <param name="teacherId">The id of the teacher who should own the deck.</param>
    /// <param name="name">The name of the deck.</param>
    /// <returns>The id of the new deck, which can then be edited via EditDeck</returns>
    [HttpPost("newdeck")]
    public int NewDeck(string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck deck = new Deck
        {
            Name = name,
            TeacherId = teacher.TeacherId
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
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsDeck = da.Decks.OwnedByTeacher(deckId, teacher.TeacherId);
        if (!ownsDeck) throw new LanguagesUnauthorized();

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
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        bool ownsDeck = da.Decks.OwnedByTeacher(card.DeckId, teacher.TeacherId);
        if (!ownsDeck) throw new LanguagesUnauthorized();

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
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        bool ownsDeck = da.Decks.OwnedByTeacher(card.DeckId, teacher.TeacherId);
        if (!ownsDeck) throw new LanguagesUnauthorized();

        db.Cards.Remove(card);
        db.SaveChanges();
    }

    [HttpGet("tasksummary")]
    public void TaskSummary(int taskId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsTask = da.Tasks.OwnedByTeacher(taskId, teacher.TeacherId);
        if (!ownsTask) throw new LanguagesUnauthorized();

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        // TODO: Build summary
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
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsClass = da.Classes.OwnedByTeacher(classId, teacher.TeacherId);
        if (!ownsClass) throw new LanguagesUnauthorized();

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
        Teacher teacher = shield.AuthenticateTeacher(Request);

        bool ownsTask = da.Tasks.OwnedByTeacher(taskId, teacher.TeacherId);
        if (!ownsTask) throw new LanguagesUnauthorized();

        Task? task = da.Tasks.ById(taskId);
        if (task == null) throw new LanguagesResourceNotFound();

        task.DeckId = deckId;
        task.DueDate = dueDate;

        db.SaveChanges();
    }
}