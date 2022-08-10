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

    public IQueryable<Card?> ForId(int id)
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
               where task.DueDate > DateTime.Now
               join card in db.Cards on task.DeckId equals card.DeckId
               join attempt in db.StudentAttempts on card.CardId equals attempt.CardId into attempts
               where attempts.Max(a => a.QuestionType) < (int)QuestionType.ForeignWritten
               let latestAttempt = attempts.OrderByDescending(a => a.AttemptDate).FirstOrDefault()
               let nextQuestionType = latestAttempt == null ?
                    (int)QuestionType.MultipleChoice :
                    (latestAttempt.Correct ?
                        latestAttempt.QuestionType + 1 :
                        latestAttempt.QuestionType - 1
                    )
               orderby task.DueDate
               select new CardVm
               {
                   CardId = card.CardId,
                   EnglishTerm = card.EnglishTerm,
                   ForeignTerm = card.ForeignTerm,
                   DueDate = task.DueDate,
                   NextQuestionType = nextQuestionType < 1 ?
                        QuestionType.MultipleChoice :
                        (QuestionType)nextQuestionType
               };
    }
}