using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/deck")]
public class TeacherDeckController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public TeacherDeckController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    /// <summary>
    /// Gets a summary of a deck of cards.
    /// </summary>
    /// <param name="deckId">The id of the deck to inspect.</param>
    /// <returns>The summary object.</returns>
    [HttpGet]
    public DeckSummaryVm Get(int deckId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ForId(deckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        List<Card> cards = da.Cards.ForDeck(deckId).ToList();

        return new DeckSummaryVm
        {
            DeckDetails = new DeckVm
            {
                DeckId = deck.DeckId,
                Name = deck.Name,
                NumCards = cards.Count(),
                CreationDate = deck.CreationDate.ToShortDateString()
            },
            Cards = cards
        };
    }

    /// <summary>
    /// Creates a new deck.
    /// </summary>
    /// <param name="name">The name of the deck to create.</param>
    /// <returns>The newly created deck (including the id).</returns>
    [HttpPost]
    public Deck Post(string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck deck = new Deck
        {
            TeacherId = teacher.TeacherId,
            Name = name,
            CreationDate = DateTime.Now
        };

        db.Decks.Add(deck);
        db.SaveChanges();

        return deck;
    }

    /// <summary>
    /// Edits a pre-existing deck.
    /// </summary>
    /// <param name="deckId">The id of the deck to edit.</param>
    /// <param name="name">The new name of the deck.</param>
    /// <returns>The edited deck.</returns>
    [HttpPatch]
    public Deck Patch(int deckId, string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ForId(deckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        deck.Name = name;
        db.SaveChanges();

        return deck;
    }

    /// <summary>
    /// Deletes a deck from the database.
    /// </summary>
    /// <param name="deckId">The id of the deck to delete.</param>
    [HttpDelete]
    public void Delete(int deckId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ForId(deckId).SingleOrDefault();
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Decks.Remove(deck);
        db.SaveChanges();
    }
}