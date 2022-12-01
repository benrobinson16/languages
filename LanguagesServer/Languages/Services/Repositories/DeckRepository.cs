using Languages.DbModels;
using Languages.ApiModels;

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

    public bool OwnedByTeacher(int deckId, int teacherId)
    {
        Deck? deck = ForId(deckId).SingleOrDefault();
        return deck?.TeacherId == teacherId;
    }
}