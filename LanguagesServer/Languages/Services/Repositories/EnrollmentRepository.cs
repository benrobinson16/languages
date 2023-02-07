using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Services.Repositories;

public class EnrollmentRepository
{
	private DatabaseContext db;

	public EnrollmentRepository(DatabaseContext db)
	{
		this.db = db;
	}

	/// <summary>
    /// Gets enrollments for a given class.
    /// </summary>
    /// <param name="classId">The class id.</param>
    /// <returns>A query for enrollments in that class.</returns>
	public IQueryable<Enrollment> ForClass(int classId)
	{
		return from enrol in db.Enrollments
			   where enrol.ClassId == classId
			   select enrol;
	}

	/// <summary>
    /// Gets enrollment view models for a student. Includes
    /// the teacher's name in addition to standard fields.
    /// </summary>
    /// <param name="studentId">The id of the student.</param>
    /// <returns>A query for enrollment view models.</returns>
	public IQueryable<EnrollmentVm> VmsForStudent(int studentId)
    {
		return from enrol in db.Enrollments
			   where enrol.StudentId == studentId
			   join cla in db.Classes on enrol.ClassId equals cla.ClassId
			   join teacher in db.Teachers on cla.TeacherId equals teacher.TeacherId
			   orderby enrol.JoinDate descending
			   select new EnrollmentVm
			   {
				   ClassId = cla.ClassId,
				   ClassName = cla.Name,
				   TeacherName = teacher.DisplayName
			   };
    }

	public IQueryable<Enrollment> ForId(int classId, int studentId)
    {
		return from enrol in db.Enrollments
			   where enrol.StudentId == studentId
					 && enrol.ClassId == classId
			   select enrol;
    }

	public void RemoveForClass(int classId)
    {
		IQueryable<Enrollment> enrollments = ForClass(classId);
		db.Enrollments.RemoveRange(enrollments);
	}
}