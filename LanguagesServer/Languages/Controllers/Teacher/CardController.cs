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

    /// <summary>
    /// Gets the details of a card.
    /// </summary>
    /// <param name="cardId">The id of the card to obtain.</param>
    /// <returns>The card object.</returns>
    [HttpGet]
    public Card Get(int cardId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ForId(cardId).SingleOrDefault();
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? deck = da.Decks.ForId(card.DeckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return card;
    }

    /// <summary>
    /// Creates a new card in the provided deck.
    /// </summary>
    /// <param name="deckId">The deck to add the card to.</param>
    /// <param name="englishTerm">The English translation of the card.</param>
    /// <param name="foreignTerm">The foreign translation of the card.</param>
    /// <returns>The newly created card, containing the id.</returns>
    [HttpPost]
    public Card Post(int deckId, string? englishTerm, string? foreignTerm)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ForId(deckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        Card card = new Card
        {
            DeckId = deckId,
            EnglishTerm = englishTerm ?? "",
            ForeignTerm = foreignTerm ?? "",
            Difficulty = da.Cards.AverageDifficulty()
        };

        db.Cards.Add(card);
        db.SaveChanges();

        return card;
    }

    /// <summary>
    /// Edits an already created card.
    /// </summary>
    /// <param name="cardId">The id of the card to edit.</param>
    /// <param name="deckId">The id of the deck to now assign this card to.</param>
    /// <param name="englishTerm">The new English term.</param>
    /// <param name="foreignTerm">The new foreign translation.</param>
    /// <returns>The newly edited card.</returns>
    [HttpPatch]
    public Card Patch(int cardId, int deckId, string? englishTerm, string? foreignTerm)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ForId(cardId).SingleOrDefault();
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? originalDeck = da.Decks.ForId(card.DeckId).SingleOrDefault();
        if (originalDeck == null) throw new LanguagesResourceNotFound();
        if (originalDeck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        if (deckId != originalDeck.DeckId)
        {
            Deck? newDeck = da.Decks.ForId(deckId).SingleOrDefault();
            if (newDeck == null) throw new LanguagesResourceNotFound();
            if (newDeck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

            card.DeckId = deckId;
        }

        card.EnglishTerm = englishTerm ?? card.EnglishTerm;
        card.ForeignTerm = foreignTerm ?? card.ForeignTerm;

        db.SaveChanges();

        return card;
    }

    /// <summary>
    /// Deletes a card from a deck.
    /// </summary>
    /// <param name="cardId">The id of the card to delete.</param>
    [HttpDelete]
    public Card Delete(int cardId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Card? card = da.Cards.ForId(cardId).SingleOrDefault();
        if (card == null) throw new LanguagesResourceNotFound();

        Deck? deck = da.Decks.ForId(card.DeckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Cards.Remove(card);
        da.StudentAttempts.RemoveForCard(cardId);
        db.SaveChanges();

        return card;
    }
}