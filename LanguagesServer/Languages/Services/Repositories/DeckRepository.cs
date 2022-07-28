using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class DeckRepository
{
    DatabaseContext db;

    public DeckRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public async Task<Deck?> ById(int id)
    {
        var deckQry = from deck in db.Decks
                      where deck.DeckId == id
                      select deck;

        return await deckQry.FirstOrDefaultAsync();
    }

    public async Task<List<Deck>> ForTeacher(int teacherId)
    {
        var deckQry = from deck in db.Decks
                      where deck.TeacherId == teacherId
                      select deck;

        return await deckQry.ToListAsync();
    }

    public async Task<bool> OwnedByTeacher(int deckId, int teacherId)
    {
        Deck? deck = await ById(deckId);
        return deck?.TeacherId == teacherId;
    }
}