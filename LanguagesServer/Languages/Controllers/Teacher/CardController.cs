using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/card")]
public class TeacherCardController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherCardController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet]
    public Card Get(int cardId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? deck = da.Decks.ById(card.DeckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return card;
    }

    [HttpPost]
    public Card Post(int deckId, string englishTerm, string foreignTerm)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        Card card = new Card
        {
            DeckId = deckId,
            EnglishTerm = englishTerm,
            ForeignTerm = foreignTerm,
            Difficulty = 0.5
        };

        db.Cards.Add(card);
        db.SaveChanges();

        return card;
    }

    [HttpPatch]
    public Card Patch(int cardId, int deckId, string englishTerm, string foreignTerm)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? originalDeck = da.Decks.ById(card.DeckId);
        if (originalDeck == null) throw new LanguagesResourceNotFound();
        if (originalDeck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        if (deckId != originalDeck.DeckId)
        {
            Deck? newDeck = da.Decks.ById(deckId);
            if (newDeck == null) throw new LanguagesResourceNotFound();
            if (newDeck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

            card.DeckId = deckId;
        }

        card.EnglishTerm = englishTerm;
        card.ForeignTerm = foreignTerm;
        db.SaveChanges();

        return card;
    }

    [HttpDelete]
    public void Delete(int cardId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? deck = da.Decks.ById(card.DeckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Cards.Remove(card);
        db.SaveChanges();
    }
}