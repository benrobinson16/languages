using Languages.Models;

namespace Languages.Services.Repositories;

public class TeacherRepository
{
    DatabaseContext db;

    public TeacherRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public Teacher? ByEmail(string email)
    {
        var qry = from teacher in db.Teachers
                  where teacher.Email == email
                  select teacher;

        return qry.FirstOrDefault();
    }
}
