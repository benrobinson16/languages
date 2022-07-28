﻿using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class CardRepository
{
    DatabaseContext db;

    public CardRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public async Task<Card?> ById(int id)
    {
        var cardQry = from card in db.Cards
                      where card.CardId == id
                      select card;

        return await cardQry.FirstOrDefaultAsync();
    }

    public async Task<List<Card>> ForDeck(int deckId)
    {
        var cardQry = from card in db.Cards
                      where card.DeckId == deckId
                      select card;

        return await cardQry.ToListAsync();
    }
}