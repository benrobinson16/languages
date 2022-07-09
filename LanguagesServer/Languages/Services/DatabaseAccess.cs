using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Services;

public class DatabaseAccess
{
    DatabaseContext db;

    public DatabaseAccess(DatabaseContext db)
    {
        this.db = db;
    }

    public Student? GetStudentByEmail(string email)
    {
        var qry = from student in db.Students
                  where student.Email == email
                  select student;
        return qry.FirstOrDefault();
    }

    public Teacher? GetTeacherByEmail(string email)
    {
        var qry = from teacher in db.Teachers
                  where teacher.Email == email
                  select teacher;
        return qry.FirstOrDefault();
    }
}

