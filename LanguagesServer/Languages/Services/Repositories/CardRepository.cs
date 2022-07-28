using Languages.DbModels;

namespace Languages.Services.Repositories;

public class CardRepository
{
    DatabaseContext db;

    public CardRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public Card? ById(int id)
    {
        var cardQry = from card in db.Cards
                      where card.CardId == id
                      select card;

        return cardQry.FirstOrDefault();
    }

    public List<Card> ForDeck(int deckId)
    {
        var cardQry = from card in db.Cards
                      where card.DeckId == deckId
                      select card;

        return cardQry.ToList();
    }
}