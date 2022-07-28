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
    public async Task<Card> Get(int cardId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Card? card = await da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? deck = await da.Decks.ById(card.DeckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return card;
    }

    [HttpPost]
    public async Task<Card> Post(int deckId, string englishTerm, string foreignTerm)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Deck? deck = await da.Decks.ById(deckId);
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
        await db.SaveChangesAsync();

        return card;
    }

    [HttpPatch]
    public async Task<Card> Patch(int cardId, int deckId, string englishTerm, string foreignTerm)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Card? card = await da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? originalDeck = await da.Decks.ById(card.DeckId);
        if (originalDeck == null) throw new LanguagesResourceNotFound();
        if (originalDeck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        if (deckId != originalDeck.DeckId)
        {
            Deck? newDeck = await da.Decks.ById(deckId);
            if (newDeck == null) throw new LanguagesResourceNotFound();
            if (newDeck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

            card.DeckId = deckId;
        }

        card.EnglishTerm = englishTerm;
        card.ForeignTerm = foreignTerm;
        await db.SaveChangesAsync();

        return card;
    }

    [HttpDelete]
    public async void Delete(int cardId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Card? card = await da.Cards.ById(cardId);
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? deck = await da.Decks.ById(card.DeckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Cards.Remove(card);
        await db.SaveChangesAsync();
    }
}