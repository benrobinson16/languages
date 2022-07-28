using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class StudentRepository
{
    DatabaseContext db;

    public StudentRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public async Task<Student?> ByEmail(string email)
    {
        var qry = from student in db.Students
                  where student.Email == email
                  select student;

        return await qry.FirstOrDefaultAsync();
    }

    public async Task<bool> ExistingForEmail(string email)
    {
        var qry = from student in db.Students
                  where student.Email == email
                  select student;

        return await qry.AnyAsync();
    }
}