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

    public Student? ByEmail(string email)
    {
        var qry = from student in db.Students
                  where student.Email == email
                  select student;

        return qry.FirstOrDefault();
    }

    public bool ExistingForEmail(string email)
    {
        var qry = from student in db.Students
                  where student.Email == email
                  select student;

        return qry.Any();
    }
}