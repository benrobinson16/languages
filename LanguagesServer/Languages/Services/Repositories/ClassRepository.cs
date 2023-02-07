using Languages.ApiModels;
using Languages.DbModels;
using Task = Languages.DbModels.Task;

namespace Languages.Services.Repositories;

public class ClassRepository
{
    private DatabaseContext db;

    public ClassRepository(DatabaseContext db)
    {
        this.db = db;
    }

    /// <summary>
    /// Gets classes with the provided id.
    /// </summary>
    /// <param name="id">The class id.</param>
    /// <returns>A query for classes with the id.</returns>
    public IQueryable<Class> ForId(int id)
    {
        return from cla in db.Classes
               where cla.ClassId == id
               select cla;
    }

    /// <summary>
    /// Gets classes belonging to a given teacher.
    /// </summary>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>A query for classes belonging to the teacher.</returns>
    public IQueryable<Class> ForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               select cla;
    }

    /// <summary>
    /// Get a set of view models for a given teacher with information
    /// such as number of students and numbe rof active tasks.
    /// </summary>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>A query for class view models.</returns>
    public IQueryable<ClassVm> VmsForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               let students = db.Enrollments
                    .Where(e => e.ClassId == cla.ClassId)
                    .Count()
               let tasks = db.Tasks
                    .Where(t => t.DueDate > DateTime.Now && t.ClassId == cla.ClassId)
                    .Count()
               orderby cla.ClassId descending
               select new ClassVm
               {
                   Id = cla.ClassId,
                   Name = cla.Name,
                   JoinCode = cla.JoinCode,
                   NumStudents = students,
                   NumActiveTasks = tasks
               };
    }

    /// <summary>
    /// Checks if a class is owned by the given teacher.
    /// </summary>
    /// <param name="classId">The id of the class.</param>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns></returns>
    public bool OwnedByTeacher(int classId, int teacherId)
    {
        Class? targetClass = ForId(classId).SingleOrDefault();
        return targetClass?.TeacherId == teacherId;
    }

    /// <summary>
    /// Checks if a given join code already exists in the database.
    /// </summary>
    /// <param name="joinCode">The join code to check.</param>
    /// <returns>Whether the join code exists.</returns>
    public bool JoinCodeExists(string joinCode)
    {
        var classQry = from cla in db.Classes
                       where cla.JoinCode == joinCode
                       select cla;

        return classQry.Any();
    }
}