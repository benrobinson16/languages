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

    public async Task<Teacher?> ByEmail(string email)
    {
        var qry = from teacher in db.Teachers
                  where teacher.Email == email
                  select teacher;

        return await qry.FirstOrDefaultAsync();
    }

    public async Task<bool> ExistingForEmail(string email)
    {
        var qry = from teacher in db.Teachers
                  where teacher.Email == email
                  select teacher;

        return await qry.AnyAsync();
    }
}
