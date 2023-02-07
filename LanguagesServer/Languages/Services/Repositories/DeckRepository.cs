using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Services.Repositories;

public class DeckRepository
{
    private DatabaseContext db;

    public DeckRepository(DatabaseContext db)
    {
        this.db = db;
    }

    /// <summary>
    /// Gets decks with the provided id.
    /// </summary>
    /// <param name="id">The id to search for.</param>
    /// <returns>A query for decks with the id.</returns>
    public IQueryable<Deck> ForId(int id)
    {
        return from deck in db.Decks
               where deck.DeckId == id
               select deck;
    }

    /// <summary>
    /// Gets decks that have been created by a given teacher.
    /// </summary>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>A query for decks belonging to the teacher.</returns>
    public IQueryable<Deck> ForTeacher(int teacherId)
    {
        return from deck in db.Decks
               where deck.TeacherId == teacherId
               select deck;
    }

    /// <summary>
    /// Gets deck view models that belong to a given teacher. Includes
    /// the number of cards that have been added to the deck.
    /// </summary>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>A query for deck view models.</returns>
    public IQueryable<DeckVm> VmsForTeacher(int teacherId)
    {
        return from deck in db.Decks
               where deck.TeacherId == teacherId
               let numCards = db.Cards.Where(c => c.DeckId == deck.DeckId).Count()
               orderby deck.CreationDate descending
               select new DeckVm
               {
                   DeckId = deck.DeckId,
                   Name = deck.Name,
                   NumCards = numCards,
                   CreationDate = deck.CreationDate
               };
    }

    /// <summary>
    /// Checks if a given deck belongs to a teacher.
    /// </summary>
    /// <param name="deckId">The deck to check.</param>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>Whether the teacher owns the deck.</returns>
    public bool OwnedByTeacher(int deckId, int teacherId)
    {
        Deck? deck = ForId(deckId).SingleOrDefault();
        return deck?.TeacherId == teacherId;
    }
}