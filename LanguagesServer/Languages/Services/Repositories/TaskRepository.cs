using Languages.DbModels;
using HwTask = Languages.DbModels.Task;
using Microsoft.EntityFrameworkCore;

namespace Languages.Services.Repositories;

public class TaskRepository
{
    DatabaseContext db;

    public TaskRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public async Task<HwTask?> ById(int id)
    {
        var taskQry = from task in db.Tasks
                      where task.TaskId == id
                      select task;

        return await taskQry.FirstOrDefaultAsync();
    }

    public async Task<List<HwTask>> ForStudent(int studentId)
    {
        var taskQry = from enrollment in db.Enrollments
                      where enrollment.StudentId == studentId
                      join cla in db.Classes on enrollment.ClassId equals cla.ClassId
                      join task in db.Tasks on cla.ClassId equals task.TaskId
                      orderby task.DueDate descending
                      select task;

        return await taskQry.ToListAsync();
    }

    public async Task<List<HwTask>> ForTeacher(int teacherId)
    {
        var taskQry = from cla in db.Classes
                      where cla.TeacherId == teacherId
                      join task in db.Tasks on cla.ClassId equals task.TaskId
                      orderby task.DueDate descending
                      select task;

        return await taskQry.ToListAsync();
    }

    public async Task<bool> OwnedByTeacher(int taskId, int teacherId)
    {
        var classQry = from task in db.Tasks
                       where task.TaskId == taskId
                       join cla in db.Classes on task.ClassId equals cla.ClassId
                       select cla;

        Class? taskClass = await classQry.FirstOrDefaultAsync();
        return taskClass?.TeacherId == teacherId;
    }

    public async Task<bool> AssignedToStudent(int taskId, int studentId)
    {
        var studentQry = from task in db.Tasks
                         where task.TaskId == taskId
                         join enrollment in db.Enrollments on task.ClassId equals enrollment.ClassId
                         select enrollment.StudentId;

        return await studentQry.ContainsAsync(studentId);
    }

    public async Task<List<HwTask>> ActiveForClass(int classId)
    {
        var taskQry = from task in db.Tasks
                      where task.ClassId == classId
                      where task.DueDate > DateTime.Now
                      select task;

        return await taskQry.ToListAsync();
    }
}