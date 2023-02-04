using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services.Repositories;

public class CardRepository
{
    DatabaseContext db;

    public CardRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public IQueryable<Card> ForId(int id)
    {
        return from card in db.Cards
               where card.CardId == id
               select card;
    }

    public IQueryable<Card> ForDeck(int deckId)
    {
        return from card in db.Cards
               where card.DeckId == deckId
               select card;
    }

    public IQueryable<CardVm> TaskVmsForStudent(int studentId)
    {
        return from enrol in db.Enrollments
               where enrol.StudentId == studentId
               join task in db.Tasks on enrol.ClassId equals task.ClassId
               where task.DueDate >= enrol.JoinDate
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
               let latestAttemptAtCard = (
                   from attempt in db.StudentAttempts
                   where attempt.CardId == card.CardId
                   where attempt.StudentId == enrol.StudentId
                   where attempt.AttemptDate >= task.SetDate
                   orderby attempt.AttemptDate descending
                   select attempt
               ).FirstOrDefault()
               let nextQuestionType = latestAttemptAtCard == null ?
                   (int)QuestionType.MultipleChoice :
                   (latestAttemptAtCard.Correct ?
                       latestAttemptAtCard.QuestionType + 1 :
                       latestAttemptAtCard.QuestionType - 1
                   )
               where greatestAttemptAtCard < (int)QuestionType.ForeignWritten
               orderby task.DueDate
               select new CardVm
               {
                   CardId = card.CardId,
                   EnglishTerm = card.EnglishTerm,
                   ForeignTerm = card.ForeignTerm,
                   DueDate = task.DueDate,
                   NextQuestionType = nextQuestionType < 1 ? QuestionType.MultipleChoice : (QuestionType)nextQuestionType
               };
    }

    public IQueryable<Card> RandomSampleForStudent(int studentId)
    {
        return from enr in db.Enrollments
               where enr.StudentId == studentId
               join task in db.Tasks on enr.ClassId equals task.ClassId
               where task.DueDate >= enr.JoinDate
               join card in db.Cards on task.DeckId equals card.DeckId
               orderby Guid.NewGuid() // random order
               select card;
    }

    public void UpdateDifficulty(int cardId)
    {
        int numCorrect = db.StudentAttempts.Where(a => a.CardId == cardId && a.Correct).Count();
        int numIncorrect = db.StudentAttempts.Where(a => a.CardId == cardId && !a.Correct).Count();
        double difficulty = (numIncorrect + (5 * AverageDifficulty())) / (numIncorrect + numCorrect + 5);

        Card card = ForId(cardId).Single();
        card.Difficulty = difficulty;
        db.SaveChanges();
    }

    public void RemoveForDeck(int deckId)
    {
        IQueryable<Card> cards = ForDeck(deckId);
        db.Cards.RemoveRange(cards);
    }

    public IQueryable<Card> SiblingsForCard(int cardId)
    {
        return from card in db.Cards
               where card.CardId == cardId
               join sibling in db.Cards on card.DeckId equals sibling.DeckId
               where sibling.CardId != cardId
               select sibling;
    }

    public Card RandomCard()
    {
        int maxSkip = db.Cards.Count();
        int skip = new Random().Next() % maxSkip;
        return db.Cards.Skip(skip).First();
    }

    public double AverageDifficulty()
    {
        double incorrectAnswers = db.StudentAttempts.Where(a => !a.Correct).Count();
        double totalAnswers = db.StudentAttempts.Count();

        // Provide a sensible default if we do not have enough data.
        if (totalAnswers < 5 || incorrectAnswers < 5) return 0.3;

        return incorrectAnswers / totalAnswers;
    }
}