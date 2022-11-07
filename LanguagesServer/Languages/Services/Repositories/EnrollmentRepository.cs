﻿using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Services.Repositories;

public class EnrollmentRepository
{
	DatabaseContext db;

	public EnrollmentRepository(DatabaseContext db)
	{
		this.db = db;
	}

	public IQueryable<Enrollment> ForClass(int classId)
	{
		return from enrol in db.Enrollments
			   where enrol.ClassId == classId
			   select enrol;
	}

	public IQueryable<EnrollmentVm> VmsForStudent(int studentId)
    {
		return from enrol in db.Enrollments
			   where enrol.StudentId == studentId
			   join cla in db.Classes on enrol.ClassId equals cla.ClassId
			   join teacher in db.Teachers on cla.TeacherId equals teacher.TeacherId
			   select new EnrollmentVm
			   {
				   ClassId = cla.ClassId,
				   ClassName = cla.Name,
				   TeacherName = teacher.DisplayName
			   };
    }

	public IQueryable<Enrollment> ById(int classId, int studentId)
    {
		return from enrol in db.Enrollments
			   where enrol.StudentId == studentId
					 && enrol.ClassId == classId
			   select enrol;
    }

	public IQueryable<Enrollment> ForEmail(string email)
    {
		return from student in db.Students
			   where student.Email == email
			   join enrol in db.Enrollments on student.StudentId equals enrol.StudentId
			   select enrol;
    }
}