using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class TeacherRepository
{
    private DatabaseContext db;

    public TeacherRepository(DatabaseContext db)
    {
        this.db = db;
    }

    /// <summary>
    /// Gets teacher with the provided email address.
    /// </summary>
    /// <param name="email">The email to search.</param>
    /// <returns>A query for matching teachers.</returns>
    public IQueryable<Teacher> ForEmail(string email)
    {
        return from teacher in db.Teachers
               where teacher.Email == email
               select teacher;
    }
}
