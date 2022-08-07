using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

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
}