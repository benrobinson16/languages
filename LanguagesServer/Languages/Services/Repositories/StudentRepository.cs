﻿using Languages.DbModels;

namespace Languages.Services.Repositories;

public class StudentRepository
{
    private DatabaseContext db;

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