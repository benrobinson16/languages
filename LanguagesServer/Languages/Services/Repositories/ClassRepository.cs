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

    public IQueryable<Class> ForId(int id)
    {
        return from cla in db.Classes
               where cla.ClassId == id
               select cla;
    }

    public IQueryable<Class> ForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               select cla;
    }

    public IQueryable<ClassVm> VmsForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               let students = db.Enrollments.Where(e => e.ClassId == cla.ClassId).Count()
               let tasks = db.Tasks.Where(t => t.DueDate > DateTime.Now && t.ClassId == cla.ClassId).Count()
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

    public bool OwnedByTeacher(int classId, int teacherId)
    {
        Class? targetClass = ForId(classId).SingleOrDefault();
        return targetClass?.TeacherId == teacherId;
    }

    public bool JoinCodeExists(string joinCode)
    {
        var classQry = from cla in db.Classes
                       where cla.JoinCode == joinCode
                       select cla;

        return classQry.Any();
    }
}