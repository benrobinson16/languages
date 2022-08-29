using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services.Repositories;

public class StudentAttemptRepository
{
    DatabaseContext db;

    public StudentAttemptRepository(DatabaseContext db)
    {
        this.db = db;
    }

    // This method returns a list rather than an IQueryable conforming type because it requires client-side
    // computation in addition to the commands performed by SQL server. This is due to issues with the EFCore
    // framework translating LINQ query syntax to SQL for queries involving outer joins/group by statements.
    public List<StudentProgress> ProgressForTask(int deckId, int classId)
    {
        List<Card> cards = (from card in db.Cards
                            where card.DeckId == deckId
                            select card).ToList();

        int expectedQuestions = cards.Count() * (int)QuestionType.ForeignWritten;

        List<Student> students = (from enrol in db.Enrollments
                                  where enrol.ClassId == classId
                                  join student in db.Students on enrol.StudentId equals student.StudentId
                                  select student).ToList();

        List<StudentProgress> progresses = new List<StudentProgress>();
        foreach (Student student in students)
        {
            int numCompleted = 0;

            foreach (Card card in cards)
            {
                StudentAttempt? latestAttempt = (from attempt in db.StudentAttempts
                                                 where attempt.StudentId == student.StudentId
                                                 where attempt.CardId == card.CardId
                                                 orderby attempt.AttemptDate descending
                                                 select attempt).FirstOrDefault();

                if (latestAttempt == null)
                {
                    numCompleted += 0;
                }
                else if (latestAttempt.Correct)
                {
                    numCompleted += latestAttempt.QuestionType;
                }
                else
                {
                    numCompleted += Math.Max(latestAttempt.QuestionType - 1, 0);
                }
            }

            progresses.Add(new StudentProgress
            {
                StudentId = student.StudentId,
                Name = student.DisplayName,
                Email = student.Email,
                Progress = expectedQuestions == 0 ? 100 : (int)Math.Floor(100.0 * numCompleted / expectedQuestions)
            });
        }

        return progresses;
    }

    // Is faster that calculating progress and comparing to 100%.
    public bool HasCompletedTask(int studentId, int deckId)
    {
        List<Card> cards = (from card in db.Cards
                            where card.DeckId == deckId
                            select card).ToList();

        foreach (Card card in cards)
        {
            bool hasCompleted = (from attempt in db.StudentAttempts
                                 where attempt.StudentId == studentId
                                 where attempt.CardId == card.CardId
                                 where attempt.QuestionType == (int)QuestionType.ForeignWritten
                                 where attempt.Correct
                                 select attempt).Any();

            if (!hasCompleted) return false;
        }

        return true;
    }

    public IQueryable<StudentAttempt> AttemptsInWindow(int studentId, int cardId, DateTime start, DateTime end)
    {
        return from attempt in db.StudentAttempts
               where attempt.StudentId == studentId
               where attempt.CardId == cardId
               where attempt.AttemptDate >= start
               where attempt.AttemptDate < end
               select attempt;
    }

    public IQueryable<StudentAttempt> CorrectAttemptsInWindow(int studentId, int cardId, DateTime start, DateTime end)
    {
        return AttemptsInWindow(studentId, cardId, start, end)
            .Where(attempt => attempt.Correct);
    }

    public IQueryable<StudentAttempt> AllAttemptsInWindow(int studentId, DateTime start, DateTime end)
    {
        return from attempt in db.StudentAttempts
               where attempt.StudentId == studentId
               where attempt.AttemptDate >= start
               where attempt.AttemptDate < end
               select attempt;
    }

    public List<StreakDay> StreakHistoryForStudent(int studentId)
    {
        List<StreakDay> streakDays = new List<StreakDay>();

        DateTime date = DateTime.Now.Date;
        for (int i = 0; i < 7; i++)
        {
            bool didAttempt = AllAttemptsInWindow(studentId, date, date.AddDays(1)).Any();

            streakDays.Add(new StreakDay
            {
                Date = date.ToShortDateString(),
                DidAttempt = didAttempt
            });

            date = date.AddDays(-1);
        }

        return streakDays;
    }

    public int StreakLengthForStudent(int studentId)
    {
        int numDays = 0;
        bool didAttempt = true;
        DateTime date = DateTime.Now.Date;

        while (didAttempt)
        {
            didAttempt = AllAttemptsInWindow(studentId, date, date.AddDays(1)).Any();
            date = date.AddDays(-1);

            if (didAttempt) numDays += 1;
        }

        return numDays;
    }
}

