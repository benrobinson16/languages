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

    public IQueryable<Student> ForEmail(string email)
    {
        return from student in db.Students
               where student.Email == email
               select student;
    }

    public IQueryable<Student> ForClass(int classId)
    {
        return from enrol in db.Enrollments
               where enrol.ClassId == classId
               join stu in db.Students on enrol.StudentId equals stu.StudentId
               orderby stu.Surname, stu.FirstName
               select stu;
    }

    public IQueryable<Student> ForId(int studentId)
    {
        return from student in db.Students
               where student.StudentId == studentId
               select student;
    }

    public IQueryable<Student> ForDailyReminders()
    {
        return from student in db.Students
               where student.DailyReminderEnabled
               where student.ReminderTime.TimeOfDay >= DateTime.Now.TimeOfDay
               where student.ReminderTime.TimeOfDay < DateTime.Now.AddMinutes(5).TimeOfDay
               where !(from attempt in db.StudentAttempts
                       where attempt.StudentId == student.StudentId
                       where attempt.AttemptDate.Date == DateTime.Now.Date
                       select attempt).Any()
               select student;
    }
}