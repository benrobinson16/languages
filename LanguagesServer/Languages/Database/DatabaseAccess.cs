using Microsoft.EntityFrameworkCore;
using Languages.Models;
using Task = Languages.Models.Task;
using System.Linq;

namespace Languages.Database;

public class DatabaseAccess
{
    public List<Class> ClassesForStudent(DatabaseContext db, int studentId)
    {
        var qry = from enr in db.Enrollments
                  join cla in db.Classes on enr.ClassId equals cla.ClassId
                  where enr.StudentId == studentId
                  select cla;
        return qry.ToList();
    }

    public List<Class> ClassesForTeacher(DatabaseContext db, int teacherId)
    {
        var qry = from cla in db.Classes
                  where cla.TeacherId == teacherId
                  select cla;
        return qry.ToList();
    }

    public List<Task> TasksForStudent(DatabaseContext db, int studentId)
    {
        var qry = from enr in db.Enrollments
                  join cla in db.Classes on enr.ClassId equals cla.ClassId
                  join task in db.Tasks on cla.ClassId equals task.ClassId
                  where enr.StudentId == studentId
                  select task;
        return qry.ToList();
    }
}

