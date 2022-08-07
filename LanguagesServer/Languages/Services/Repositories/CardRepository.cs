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
}