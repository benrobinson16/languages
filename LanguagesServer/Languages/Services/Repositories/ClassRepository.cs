using Languages.Models;

namespace Languages.Services.Repositories;

public class ClassRepository
{
    DatabaseContext db;

    public ClassRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public Class? ById(int id)
    {
        var classQry = from cla in db.Classes
                       where cla.ClassId == id
                       select cla;

        return classQry.FirstOrDefault();
    }

    public List<Class> ForTeacher(int teacherId)
    {
        var classQry = from cla in db.Classes
                       where cla.TeacherId == teacherId
                       select cla;

        return classQry.ToList();
    }

    public bool OwnedByTeacher(int classId, int teacherId)
    {
        Class? targetClass = ById(classId);
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