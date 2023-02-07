using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services.Repositories;

public class StudentAttemptRepository
{
    private DatabaseContext db;

    public StudentAttemptRepository(DatabaseContext db)
    {
        this.db = db;
    }

    // This method returns a list rather than an IQueryable conforming type because it requires client-side
    // computation in addition to the commands performed by SQL server. This is due to issues with the EFCore
    // framework translating LINQ query syntax to SQL for queries involving outer joins/group by statements.
    public List<StudentProgress> ProgressForTask(int deckId, int classId, DateTime setDate)
    {
        List<Card> cards = (from card in db.Cards
                            where card.DeckId == deckId
                            select card).ToList();

        List<Student> students = (from enrol in db.Enrollments
                                  where enrol.ClassId == classId
                                  join student in db.Students on enrol.StudentId equals student.StudentId
                                  select student).ToList();

        List<StudentProgress> progresses = new List<StudentProgress>();
        foreach (Student student in students)
        {
            progresses.Add(new StudentProgress
            {
                Email = student.Email,
                StudentId = student.StudentId,
                Name = student.DisplayName,
                Progress = StudentProgress(cards, student.StudentId, setDate)
            });
        }

        return progresses
            .OrderByDescending(stu => stu.Progress)
            .ToList();
    }

    /// <summary>
    /// Gets a student's progress through a set of cards since a set date.
    /// </summary>
    /// <param name="cards">The cards to check.</param>
    /// <param name="studentId">The student's id.</param>
    /// <param name="setDate">The date to check from.</param>
    /// <returns>A rounded percentage 0...1000</returns>
    public int StudentProgress(List<Card> cards, int studentId, DateTime setDate)
    {
        int numCompleted = 0;
        int expectedQuestions = cards.Count() * (int)QuestionType.ForeignWritten;

        foreach (Card card in cards)
        {
            StudentAttempt? greatestAttempt = CorrectAttemptsInWindow(studentId, card.CardId, setDate, DateTime.Now).OrderByDescending(attempt => attempt.QuestionType).FirstOrDefault();
            
            if (greatestAttempt == null)
            {
                numCompleted += 0;
            }
            else
            {
                numCompleted += greatestAttempt.QuestionType;
            }
        }

        return expectedQuestions == 0 ? 100 : (int)Math.Floor(100.0 * numCompleted / expectedQuestions);
    }

    // Is faster that calculating progress and comparing to 100%.
    public bool HasCompletedTask(int studentId, int deckId, DateTime setDate)
    {
        List<Card> cards = (from card in db.Cards
                            where card.DeckId == deckId
                            select card).ToList();

        foreach (Card card in cards)
        {
            bool hasCompleted = CorrectAttemptsInWindow(studentId, card.CardId, setDate, DateTime.Now).Where(attempt => attempt.QuestionType == (int)QuestionType.ForeignWritten).Any();

            if (!hasCompleted) return false;
        }

        return true;
    }

    /// <summary>
    /// Queries student attempts in a given window for a given card.
    /// </summary>
    /// <param name="studentId">Student's id.</param>
    /// <param name="cardId">The id of the card to check.</param>
    /// <param name="start">The window start.</param>
    /// <param name="end">The window end.</param>
    /// <returns>A query of attempts.</returns>
    public IQueryable<StudentAttempt> AttemptsInWindow(int studentId, int cardId, DateTime start, DateTime end)
    {
        return from attempt in db.StudentAttempts
               where attempt.StudentId == studentId
               where attempt.CardId == cardId
               where attempt.AttemptDate >= start
               where attempt.AttemptDate < end
               select attempt;
    }

    /// <summary>
    /// Gets correct attempts in a given window for a given card.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <param name="cardId">The id of the card to check.</param>
    /// <param name="start">The start of the window.</param>
    /// <param name="end">The end of the window.</param>
    /// <returns>A query of attempts.</returns>
    public IQueryable<StudentAttempt> CorrectAttemptsInWindow(int studentId, int cardId, DateTime start, DateTime end)
    {
        return AttemptsInWindow(studentId, cardId, start, end)
            .Where(attempt => attempt.Correct);
    }

    /// <summary>
    /// Gets all attempts by a student in a window.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <param name="start">The start of the window.</param>
    /// <param name="end">The end of the window.</param>
    /// <returns></returns>
    public IQueryable<StudentAttempt> AllAttemptsInWindow(int studentId, DateTime start, DateTime end)
    {
        return from attempt in db.StudentAttempts
               where attempt.StudentId == studentId
               where attempt.AttemptDate >= start
               where attempt.AttemptDate < end
               select attempt;
    }

    /// <summary>
    /// Gets a list of streak days for a student in the last 7 days.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>A list of streak days.</returns>
    public List<StreakDay> StreakHistoryForStudent(int studentId)
    {
        List<StreakDay> streakDays = new List<StreakDay>();

        DateTime date = DateTime.Now.Date;
        for (int i = 0; i < 7; i++)
        {
            bool didAttempt = AllAttemptsInWindow(studentId, date, date.AddDays(1)).Any();

            streakDays.Add(new StreakDay
            {
                Date = date,
                DidAttempt = didAttempt
            });

            date = date.AddDays(-1);
        }

        return streakDays;
    }

    /// <summary>
    /// Gets a student's current streak length.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>The length of their streak.</returns>
    public int StreakLengthForStudent(int studentId)
    {
        int numDays = -1;
        bool didAttempt;
        DateTime date = DateTime.Now.Date;

        do
        {
            numDays += 1;
            didAttempt = AllAttemptsInWindow(studentId, date, date.AddDays(1)).Any();
            date = date.AddDays(-1);
        }
        while (didAttempt);

        return numDays;
    }

    /// <summary>
    /// Gets all attempts for a given card ever.
    /// </summary>
    /// <param name="cardId">The id of the card.</param>
    /// <returns>A query of attempts.</returns>
    public IQueryable<StudentAttempt> AttemptsForCard(int cardId)
    {
        return from attempt in db.StudentAttempts
               where attempt.CardId == cardId
               select attempt;
    }

    /// <summary>
    /// Geta all attempts for a given card by a given student.
    /// </summary>
    /// <param name="studentId">The id of the student.</param>
    /// <param name="cardId">The id of the card.</param>
    /// <returns>A query of attempts.</returns>
    public IQueryable<StudentAttempt> StudentAttemptsForCard(int studentId, int cardId)
    {
        return from attempt in db.StudentAttempts
               where attempt.CardId == cardId
               where attempt.StudentId == studentId
               select attempt;
    }

    /// <summary>
    /// Removes student attempts for a card.
    /// </summary>
    /// <param name="cardId">The card to remove attempts for.</param>
    public void RemoveForCard(int cardId)
    {
        IQueryable<StudentAttempt> attempts = AttemptsForCard(cardId);
        db.StudentAttempts.RemoveRange(attempts);
    }

    /// <summary>
    /// Remove all student attempts for cards in a deck.
    /// </summary>
    /// <param name="deckId">The id of the deck.</param>
    public void RemoveForDeck(int deckId)
    {
        List<Card> cards = db.Cards.Where(c => c.DeckId == deckId).ToList();
        foreach (Card card in cards)
        {
            RemoveForCard(card.CardId);
        }
    }

    /// <summary>
    /// Gets the number of days since the user last reviewed a card.
    /// </summary>
    /// <param name="cardId">The card's id.</param>
    /// <param name="studentId">Ths student's id.</param>
    /// <returns>The days since their latest attempt. Null if never attempted.</returns>
    public int? DaysSinceAttempt(int cardId, int studentId)
    {
        var qry = from attempt in db.StudentAttempts
                  where attempt.CardId == cardId
                  where attempt.StudentId == studentId
                  orderby attempt.AttemptDate descending
                  select attempt.AttemptDate;

        if (!qry.Any()) return null;

        DateTime mostRecent = qry.First();
        return DateTime.Now.Subtract(mostRecent).Days;
    }

    /// <summary>
    /// Gets the number of expected questions today. This is calculated as the
    /// sum of each task's daily required questions to complete on time.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>The expected number of questions.</returns>
    private int ExpectedQuestionsToday(int studentId)
    {
        var qry = from enrol in db.Enrollments
                  where enrol.StudentId == studentId
                  join task in db.Tasks on enrol.ClassId equals task.ClassId
                  where enrol.JoinDate <= task.DueDate
                  join card in db.Cards on task.DeckId equals card.DeckId
                  let greatestAttemptAtCard = (
                      from attempt in db.StudentAttempts
                      where attempt.CardId == card.CardId
                      where attempt.StudentId == enrol.StudentId
                      where attempt.AttemptDate.Date < DateTime.Now.Date
                      where attempt.AttemptDate >= task.SetDate
                      where attempt.Correct
                      orderby attempt.QuestionType descending
                      select attempt.QuestionType
                  ).FirstOrDefault()
                  where greatestAttemptAtCard <= (int)QuestionType.ForeignWritten
                  let questionsRequired = (int)QuestionType.ForeignWritten - greatestAttemptAtCard
                  select new { QuestionsRequired = questionsRequired, DueDate = task.DueDate };

        return (int)Math.Ceiling(qry
            .ToList()
            .Select(x =>
                x.DueDate > DateTime.Now ?
                    x.QuestionsRequired / Math.Ceiling((x.DueDate - DateTime.Now).TotalDays) :
                    x.QuestionsRequired
            )
            .Sum());
    }

    /// <summary>
    /// The minimum remaining number of questions to answer today in
    /// order to ensure all tasks due tomorrow are completed.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>The minimum number of questions due today.</returns>
    private int MinRemainingQuestionsToday(int studentId)
    {
        var qry = from enrol in db.Enrollments
                  where enrol.StudentId == studentId
                  join task in db.Tasks on enrol.ClassId equals task.ClassId
                  where enrol.JoinDate <= task.DueDate
                  where task.DueDate.Date <= DateTime.Now.AddDays(1).Date
                  join card in db.Cards on task.DeckId equals card.DeckId
                  let greatestAttemptAtCard = (
                      from attempt in db.StudentAttempts
                      where attempt.CardId == card.CardId
                      where attempt.StudentId == enrol.StudentId
                      where attempt.AttemptDate >= task.SetDate
                      where attempt.Correct
                      orderby attempt.QuestionType descending
                      select attempt.QuestionType
                  ).FirstOrDefault()
                  where greatestAttemptAtCard <= (int)QuestionType.ForeignWritten
                  let questionsRequired = (int)QuestionType.ForeignWritten - greatestAttemptAtCard
                  select questionsRequired;

        return (int)qry.Sum();
    }

    /// <summary>
    /// The number of correct questions answered today.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>The number of questions answered by the student.</returns>
    private int CardsAnsweredToday(int studentId)
    {
        var qry = from attempt in db.StudentAttempts
                  where attempt.StudentId == studentId
                  where attempt.AttemptDate.Date == DateTime.Now.Date
                  where attempt.Correct
                  select attempt;

        return qry.Count();
    }

    /// <summary>
    /// Gets the estimated percentage completion of the student
    /// through their expected daily revision.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>A percentage 0...1</returns>
    public double DailyCompletion(int studentId)
    {
        int expectedQuestions = ExpectedQuestionsToday(studentId);
        int completedQuestions = CardsAnsweredToday(studentId);
        int minRemainingQuestions = MinRemainingQuestionsToday(studentId);

        if (minRemainingQuestions + completedQuestions > expectedQuestions)
            expectedQuestions = minRemainingQuestions + completedQuestions;

        double percentage = expectedQuestions > 0
            ? (double)completedQuestions / expectedQuestions
            : 1.0;

        if (percentage < 0.0) percentage = 0.0;
        if (percentage > 1.0) percentage = 1.0;

        return percentage;
    }
}
