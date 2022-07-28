using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Controllers;

[ApiController]
[Route("/teacher/deck")]
public class DeckController : ControllerBase
{
    DatabaseContext db;
    DatabaseAccess da;
    Shield shield;

    public DeckController(DatabaseContext db, DatabaseAccess da, Shield shield)
    {
        this.db = db;
        this.da = da;
        this.shield = shield;
    }

    [HttpGet]
    public Deck Get(int deckId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return deck;
    }

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

    [HttpPatch]
    public Deck Patch(int deckId, string name)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        deck.Name = name;
        db.SaveChanges();

        return deck;
    }

    [HttpDelete]
    public void Delete(int deckId)
    {
        Teacher teacher = shield.AuthenticateTeacher(Request);

        Deck? deck = da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Decks.Remove(deck);
        db.SaveChanges();
    }
}