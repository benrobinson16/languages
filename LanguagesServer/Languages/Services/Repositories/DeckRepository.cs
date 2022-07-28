﻿using Languages.Models;

namespace Languages.Services.Repositories;

public class DeckRepository
{
    DatabaseContext db;

    public DeckRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public Deck? ById(int id)
    {
        var deckQry = from deck in db.Decks
                      where deck.DeckId == id
                      select deck;

        return deckQry.FirstOrDefault();
    }

    public List<Deck> ForTeacher(int teacherId)
    {
        var deckQry = from deck in db.Decks
                      where deck.TeacherId == teacherId
                      select deck;

        return deckQry.ToList();
    }

    public bool OwnedByTeacher(int deckId, int teacherId)
    {
        Deck? deck = ById(deckId);
        return deck?.TeacherId == teacherId;
    }
}