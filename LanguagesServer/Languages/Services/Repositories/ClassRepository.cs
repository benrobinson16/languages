using Languages.DbModels;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class ClassRepository
{
    DatabaseContext db;

    public ClassRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public async Task<Class?> ById(int id)
    {
        var classQry = from cla in db.Classes
                       where cla.ClassId == id
                       select cla;

        return await classQry.FirstOrDefaultAsync();
    }

    public async Task<List<Class>> ForTeacher(int teacherId)
    {
        var classQry = from cla in db.Classes
                       where cla.TeacherId == teacherId
                       select cla;

        return await classQry.ToListAsync();
    }

    public async Task<bool> OwnedByTeacher(int classId, int teacherId)
    {
        Class? targetClass = await ById(classId);
        return targetClass?.TeacherId == teacherId;
    }

    public async Task<bool> JoinCodeExists(string joinCode)
    {
        var classQry = from cla in db.Classes
                       where cla.JoinCode == joinCode
                       select cla;

        return await classQry.AnyAsync();
    }
}