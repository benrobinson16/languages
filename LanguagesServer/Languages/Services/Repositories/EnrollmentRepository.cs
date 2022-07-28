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

	public async Task<List<Enrollment>> ForClass(int classId)
	{
		var enrolQry = from enrol in db.Enrollments
					   where enrol.ClassId == classId
					   select enrol;

		return await enrolQry.ToListAsync();
	}
}