using Languages.DbModels;

namespace Languages.Services.Repositories;

public class StudentRepository
{
    private DatabaseContext db;

    public StudentRepository(DatabaseContext db)
    {
        this.db = db;
    }

    /// <summary>
    /// Gets students with the provided email.
    /// </summary>
    /// <param name="email">The email to search for.</param>
    /// <returns>A query for students with that email.</returns>
    public IQueryable<Student> ForEmail(string email)
    {
        return from student in db.Students
               where student.Email == email
               select student;
    }

    /// <summary>
    /// Gets students enrolled in a ceetain class.
    /// </summary>
    /// <param name="classId">The id of the class to search for.</param>
    /// <returns>A query for students in that class.</returns>
    public IQueryable<Student> ForClass(int classId)
    {
        return from enrol in db.Enrollments
               where enrol.ClassId == classId
               join stu in db.Students on enrol.StudentId equals stu.StudentId
               orderby stu.Surname, stu.FirstName
               select stu;
    }

    /// <summary>
    /// Gets students with the provided id.
    /// </summary>
    /// <param name="studentId">The search id.</param>
    /// <returns>A query for students with that id.</returns>
    public IQueryable<Student> ForId(int studentId)
    {
        return from student in db.Students
               where student.StudentId == studentId
               select student;
    }

    /// <summary>
    /// Gets students who should be delivered notifications in
    /// the next minute. I.e. those with notifications enabled, set
    /// in the next minute and who have not already practiced today.
    /// </summary>
    /// <returns>A query for students meeting these criteria.</returns>
    public IQueryable<Student> ForDailyReminders()
    {
        return from student in db.Students
               where student.DailyReminderEnabled
               let now = DateTime.Now.TimeOfDay
               let nowPlusOne = DateTime.Now.AddMinutes(1).TimeOfDay
               let target = student.ReminderTime.TimeOfDay
               where (now > nowPlusOne
                     ? target >= now || target < nowPlusOne
                     : target >= now && target < nowPlusOne)
               where !(from attempt in db.StudentAttempts
                       where attempt.StudentId == student.StudentId
                       where attempt.AttemptDate.Date == DateTime.Now.Date
                       select attempt).Any()
               select student;
    }
}