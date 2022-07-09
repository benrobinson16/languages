using Languages.Models;

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
}