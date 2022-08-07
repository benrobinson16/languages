using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class TeacherRepository
{
    DatabaseContext db;

    public TeacherRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public IQueryable<Teacher> ForEmail(string email)
    {
        return from teacher in db.Teachers
               where teacher.Email == email
               select teacher;
    }
}
