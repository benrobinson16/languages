using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Services.Repositories;

public class TaskRepository
{
    DatabaseContext db;

    public TaskRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public Task? ById(int id)
    {
        var taskQry = from task in db.Tasks
                      where task.TaskId == id
                      select task;

        return taskQry.FirstOrDefault();
    }

    public List<Task> ForStudent(int studentId)
    {
        var taskQry = from enrollment in db.Enrollments
                      where enrollment.StudentId == studentId
                      join cla in db.Classes on enrollment.ClassId equals cla.ClassId
                      join task in db.Tasks on cla.ClassId equals task.TaskId
                      orderby task.DueDate descending
                      select task;

        return taskQry.ToList();
    }

    public List<Task> ForTeacher(int teacherId)
    {
        var taskQry = from cla in db.Classes
                      where cla.TeacherId == teacherId
                      join task in db.Tasks on cla.ClassId equals task.TaskId
                      orderby task.DueDate descending
                      select task;

        return taskQry.ToList();
    }

    public bool OwnedByTeacher(int taskId, int teacherId)
    {
        var classQry = from task in db.Tasks
                       where task.TaskId == taskId
                       join cla in db.Classes on task.ClassId equals cla.ClassId
                       select cla;

        Class? taskClass = classQry.FirstOrDefault();
        return taskClass?.TeacherId == teacherId;
    }

    public bool AssignedToStudent(int taskId, int studentId)
    {
        var studentQry = from task in db.Tasks
                         where task.TaskId == taskId
                         join enrollment in db.Enrollments on task.ClassId equals enrollment.ClassId
                         select enrollment.StudentId;

        return studentQry.Contains(studentId);
    }
}