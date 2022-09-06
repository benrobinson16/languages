using Languages.DbModels;
using Task = Languages.DbModels.Task;
using Microsoft.EntityFrameworkCore;
using Languages.ApiModels;

namespace Languages.Services.Repositories;

public class TaskRepository
{
    DatabaseContext db;

    public TaskRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public IQueryable<Task> ForId(int id)
    {
        return from task in db.Tasks
               where task.TaskId == id
               select task;
    }

    public IQueryable<TaskVm> VmForId(int id)
    {
        return from task in db.Tasks
               where task.TaskId == id
               join deck in db.Decks on task.DeckId equals deck.DeckId
               join cla in db.Classes on task.ClassId equals cla.ClassId
               select new TaskVm
               {
                   Id = task.TaskId,
                   ClassId = cla.ClassId,
                   DeckId = deck.DeckId,
                   ClassName = cla.Name,
                   DeckName = deck.Name,
                   DueDate = task.DueDate.ToShortDateString()
               };
    }

    public IQueryable<Task> ForStudent(int studentId)
    {
        return from enrollment in db.Enrollments
               where enrollment.StudentId == studentId
               join cla in db.Classes on enrollment.ClassId equals cla.ClassId
               join task in db.Tasks on cla.ClassId equals task.TaskId
               orderby task.DueDate descending
               select task;
    }

    public IQueryable<TaskVm> VmsForStudent(int studentId)
    {
        return from enrollment in db.Enrollments
               where enrollment.StudentId == studentId
               join cla in db.Classes on enrollment.ClassId equals cla.ClassId
               join task in db.Tasks on cla.ClassId equals task.ClassId
               join deck in db.Decks on task.DeckId equals deck.DeckId
               orderby task.DueDate descending
               select new TaskVm
               {
                   Id = task.TaskId,
                   ClassId = cla.ClassId,
                   DeckId = deck.DeckId,
                   ClassName = cla.Name,
                   DeckName = deck.Name,
                   DueDate = task.DueDate.ToShortDateString()
               };
    }

    public IQueryable<Task> ForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               join task in db.Tasks on cla.ClassId equals task.ClassId
               orderby task.DueDate descending
               select task;
    }

    public IQueryable<TaskVm> VmsForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               join task in db.Tasks on cla.ClassId equals task.ClassId
               join deck in db.Decks on task.DeckId equals deck.DeckId
               orderby task.DueDate descending
               select new TaskVm
               {
                   Id = task.TaskId,
                   ClassId = cla.ClassId,
                   DeckId = deck.DeckId,
                   ClassName = cla.Name,
                   DeckName = deck.Name,
                   DueDate = task.DueDate.ToShortDateString()
               };
    }

    public IQueryable<Task> ForClass(int classId)
    {
        return from task in db.Tasks
               where task.ClassId == classId
               orderby task.DueDate descending
               select task;
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

    public IQueryable<Task> ActiveForClass(int classId)
    {
        return from task in db.Tasks
               where task.ClassId == classId
               where task.DueDate > DateTime.Now
               select task;
    }
}