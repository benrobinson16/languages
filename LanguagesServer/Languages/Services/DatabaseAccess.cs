using Languages.Services.Repositories;

namespace Languages.Services;

/// <summary>
/// Responsible for queries on the database.
/// </summary>
public class DatabaseAccess
{
    public CardRepository Cards;
    public ClassRepository Classes;
    public DeckRepository Decks;
    public EnrollmentRepository Enrollments;
    public StudentAttemptRepository StudentAttempts;
    public StudentRepository Students;
    public TaskRepository Tasks;
    public TeacherRepository Teachers;

    /// <summary>
    /// Creates a new DatabaseAccess layer.
    /// </summary>
    /// <param name="db">The database context to use.</param>
    public DatabaseAccess(DatabaseContext db)
    {
        this.Cards = new CardRepository(db);
        this.Classes = new ClassRepository(db);
        this.Decks = new DeckRepository(db);
        this.Enrollments = new EnrollmentRepository(db);
        this.StudentAttempts = new StudentAttemptRepository(db);
        this.Students = new StudentRepository(db);
        this.Tasks = new TaskRepository(db);
        this.Teachers = new TeacherRepository(db);
    }
}
