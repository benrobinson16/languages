using Languages.ApiModels;
using Languages.DbModels;
using Task = Languages.DbModels.Task;

namespace Languages.Services.Repositories;

public class ClassRepository
{
    DatabaseContext db;

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
        IQueryable<Task> activeTasks = from task in db.Tasks
                                       where task.DueDate > DateTime.Now
                                       select task;

        return from cla in db.Classes
               where cla.TeacherId == teacherId
               join enrol in db.Enrollments on cla.ClassId equals enrol.ClassId into students
               join task in activeTasks on cla.ClassId equals task.ClassId into tasks
               select new ClassVm
               {
                   Id = cla.ClassId,
                   Name = cla.Name,
                   JoinCode = cla.JoinCode,
                   NumStudents = students.Count(),
                   NumActiveTasks = tasks.Count()
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