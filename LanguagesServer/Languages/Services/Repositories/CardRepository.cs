using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services.Repositories;

public class CardRepository
{
    private DatabaseContext db;

    public CardRepository(DatabaseContext db)
    {
        this.db = db;
    }

    /// <summary>
    /// Gets cards based on id.
    /// </summary>
    /// <param name="id">The cardid.</param>
    /// <returns>A query for cards with that id.</returns>
    public IQueryable<Card> ForId(int id)
    {
        return from card in db.Cards
               where card.CardId == id
               select card;
    }

    /// <summary>
    /// Gets cards by the deck they're in.
    /// </summary>
    /// <param name="deckId">The id of the deck.</param>
    /// <returns>A query for cards in that deck.</returns>
    public IQueryable<Card> ForDeck(int deckId)
    {
        return from card in db.Cards
               where card.DeckId == deckId
               select card;
    }

    /// <summary>
    /// Gets cards with their current LQN state.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>A query for LQN cards with current queue.</returns>
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

    /// <summary>
    /// Gets a randomised list of cards.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>A query for all assigned cards, in random order.</returns>
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

    /// <summary>
    /// Updates the difficulty of a card.
    /// </summary>
    /// <param name="cardId">The id of the card to update.</param>
    public void UpdateDifficulty(int cardId)
    {
        int numCorrect = db.StudentAttempts.Where(a => a.CardId == cardId && a.Correct).Count();
        int numIncorrect = db.StudentAttempts.Where(a => a.CardId == cardId && !a.Correct).Count();
        double difficulty = (numIncorrect + (5 * AverageDifficulty())) / (numIncorrect + numCorrect + 5);

        Card card = ForId(cardId).Single();
        card.Difficulty = difficulty;
        db.SaveChanges();
    }

    /// <summary>
    /// Removes all cards in a deck.
    /// </summary>
    /// <param name="deckId">The deck to clear.</param>
    public void RemoveForDeck(int deckId)
    {
        IQueryable<Card> cards = ForDeck(deckId);
        db.Cards.RemoveRange(cards);
    }

    /// <summary>
    /// Gets cards in the same deck as a given card.
    /// </summary>
    /// <param name="cardId">The card to find siblings for.</param>
    /// <returns>A query for sibling cards.</returns>
    public IQueryable<Card> SiblingsForCard(int cardId)
    {
        return from card in db.Cards
               where card.CardId == cardId
               join sibling in db.Cards on card.DeckId equals sibling.DeckId
               where sibling.CardId != cardId
               select sibling;
    }

    /// <summary>
    /// Gets a random card from the database.
    /// </summary>
    /// <returns>A random card (if any).</returns>
    public Card RandomCard()
    {
        int maxSkip = db.Cards.Count();
        int skip = new Random().Next() % maxSkip;
        return db.Cards.Skip(skip).First();
    }

    /// <summary>
    /// Gets the average difficulty of the all cards.
    /// </summary>
    /// <returns>Average difficulty.</returns>
    public double AverageDifficulty()
    {
        double incorrectAnswers = db.StudentAttempts.Where(a => !a.Correct).Count();
        double totalAnswers = db.StudentAttempts.Count();

        // Provide a sensible default if we do not have enough data.
        if (totalAnswers < 5 || incorrectAnswers < 5) return 0.3;

        return incorrectAnswers / totalAnswers;
    }
}