using Microsoft.AspNetCore.Mvc;
using Languages.Services;
using Languages.DbModels;
using Languages.ApiModels;
using Task = Languages.DbModels.Task;
using Microsoft.EntityFrameworkCore;

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

    [HttpGet]
    public async Task<Deck> Get(int deckId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Deck? deck = await da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        return deck;
    }

    [HttpPost]
    public async Task<Deck> Post(string name)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Deck deck = new Deck
        {
            TeacherId = teacher.TeacherId,
            Name = name,
            CreationDate = DateTime.Now
        };

        db.Decks.Add(deck);
        await db.SaveChangesAsync();

        return deck;
    }

    [HttpPatch]
    public async Task<Deck> Patch(int deckId, string name)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Deck? deck = await da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        deck.Name = name;
        await db.SaveChangesAsync();

        return deck;
    }

    [HttpDelete]
    public async void Delete(int deckId)
    {
        Teacher teacher = await shield.AuthenticateTeacher(Request);

        Deck? deck = await da.Decks.ById(deckId);
        if (deck == null) throw new LanguagesResourceNotFound();
        if (deck.TeacherId != teacher.TeacherId) throw new LanguagesUnauthorized();

        db.Decks.Remove(deck);
        await db.SaveChangesAsync();
    }
}