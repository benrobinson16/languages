using Languages.DbModels;

namespace Languages.Services.Repositories;

public class DeckRepository
{
    DatabaseContext db;

    public DeckRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public IQueryable<Deck> ForId(int id)
    {
        return from deck in db.Decks
               where deck.DeckId == id
               select deck;
    }

    public IQueryable<Deck> ForTeacher(int teacherId)
    {
        return from deck in db.Decks
               where deck.TeacherId == teacherId
               select deck;
    }

    public bool OwnedByTeacher(int deckId, int teacherId)
    {
        Deck? deck = ForId(deckId).SingleOrDefault();
        return deck?.TeacherId == teacherId;
    }
}