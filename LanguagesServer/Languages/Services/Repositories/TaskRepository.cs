using Languages.DbModels;
using Task = Languages.DbModels.Task;
using Microsoft.EntityFrameworkCore;
using Languages.ApiModels;

namespace Languages.Services.Repositories;

public class TaskRepository
{
    private DatabaseContext db;

    public TaskRepository(DatabaseContext db)
    {
        this.db = db;
    }

    /// <summary>
    /// Gets tasks with the provided id.
    /// </summary>
    /// <param name="id">The task id.</param>
    /// <returns>A query for tasks with that id.</returns>
    public IQueryable<Task> ForId(int id)
    {
        return from task in db.Tasks
               where task.TaskId == id
               select task;
    }

    /// <summary>
    /// Gets vms for tasks with the provided id. Includes
    /// data on deck and class name in addition to normal fields.
    /// </summary>
    /// <param name="id">The task id.</param>
    /// <returns>A query for task view models with that id.</returns>
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
                   DueDate = task.DueDate,
                   SetDate = task.SetDate
               };
    }

    /// <summary>
    /// Gets tasks that have been assigned to a student.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>A query for tasks for that student.</returns>
    public IQueryable<Task> ForStudent(int studentId)
    {
        return from enrollment in db.Enrollments
               where enrollment.StudentId == studentId
               join cla in db.Classes on enrollment.ClassId equals cla.ClassId
               join task in db.Tasks on cla.ClassId equals task.TaskId
               where task.DueDate >= enrollment.JoinDate
               orderby task.DueDate descending
               select task;
    }

    /// <summary>
    /// Gets task view models that have been assigned to a student.
    /// Includes class/deck names in addition to normal fields.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <returns>A query for tasks for that student.</returns>
    public IQueryable<TaskVm> VmsForStudent(int studentId)
    {
        return from enrollment in db.Enrollments
               where enrollment.StudentId == studentId
               join cla in db.Classes on enrollment.ClassId equals cla.ClassId
               join task in db.Tasks on cla.ClassId equals task.ClassId
               where enrollment.JoinDate <= task.DueDate
               join deck in db.Decks on task.DeckId equals deck.DeckId
               orderby task.DueDate descending
               select new TaskVm
               {
                   Id = task.TaskId,
                   ClassId = cla.ClassId,
                   DeckId = deck.DeckId,
                   ClassName = cla.Name,
                   DeckName = deck.Name,
                   DueDate = task.DueDate,
                   SetDate = task.SetDate
               };
    }

    /// <summary>
    /// Get tasks set by a teacher.
    /// </summary>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>A query for tasks set by that teacher.</returns>
    public IQueryable<Task> ForTeacher(int teacherId)
    {
        return from cla in db.Classes
               where cla.TeacherId == teacherId
               join task in db.Tasks on cla.ClassId equals task.ClassId
               orderby task.DueDate descending
               select task;
    }

    /// <summary>
    /// Get task vms set by a teacher. Includes class and deck
    /// names in addition to default fields.
    /// </summary>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>A query for task vms set by that teacher.</returns>
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
                   DueDate = task.DueDate,
                   SetDate = task.SetDate
               };
    }

    /// <summary>
    /// Get tasks assigned to a class.
    /// </summary>
    /// <param name="classId">The class id.</param>
    /// <returns>A query for tasks.</returns>
    public IQueryable<Task> ForClass(int classId)
    {
        return from task in db.Tasks
               where task.ClassId == classId
               orderby task.DueDate descending
               select task;
    }

    /// <summary>
    /// Get task view movels assigned to a class. Includes
    /// class and deck names in addition to default fields.
    /// </summary>
    /// <param name="classId">The id of the class.</param>
    /// <returns>A query for task vms.</returns>
    public IQueryable<TaskVm> VmsForClass(int classId)
    {
        return from task in db.Tasks
               where task.ClassId == classId
               join deck in db.Decks on task.DeckId equals deck.DeckId
               join cla in db.Classes on task.ClassId equals cla.ClassId
               orderby task.DueDate descending
               select new TaskVm
               {
                   Id = task.TaskId,
                   ClassId = cla.ClassId,
                   DeckId = deck.DeckId,
                   ClassName = cla.Name,
                   DeckName = deck.Name,
                   DueDate = task.DueDate,
                   SetDate = task.SetDate
               };
    }

    /// <summary>
    /// Gets tasks that have been set using the provided deck.
    /// </summary>
    /// <param name="deckId">The deck's id.</param>
    /// <returns>A query fot tasks with that deck.</returns>
    public IQueryable<Task> ForDeck(int deckId)
    {
        return from task in db.Tasks
               where task.DeckId == deckId
               orderby task.DueDate descending
               select task;
    }

    /// <summary>
    /// Checks if a given task is owned by a given teacher.
    /// </summary>
    /// <param name="taskId">The task's id.</param>
    /// <param name="teacherId">The teacher's id.</param>
    /// <returns>Whether the teacher owns that task.</returns>
    public bool OwnedByTeacher(int taskId, int teacherId)
    {
        var classQry = from task in db.Tasks
                       where task.TaskId == taskId
                       join cla in db.Classes on task.ClassId equals cla.ClassId
                       select cla;

        Class? taskClass = classQry.FirstOrDefault();
        return taskClass?.TeacherId == teacherId;
    }

    /// <summary>
    /// Checks if a given task has been assigned to a student/
    /// </summary>
    /// <param name="taskId">The id of the task.</param>
    /// <param name="studentId">The student's id.</param>
    /// <returns></returns>
    public bool AssignedToStudent(int taskId, int studentId)
    {
        var studentQry = from task in db.Tasks
                         where task.TaskId == taskId
                         join enrollment in db.Enrollments on task.ClassId equals enrollment.ClassId
                         where enrollment.JoinDate <= task.DueDate
                         select enrollment.StudentId;

        return studentQry.Contains(studentId);
    }

    /// <summary>
    /// Gets tasks that are active (before due date) for a given class.
    /// </summary>
    /// <param name="classId">The class id.</param>
    /// <returns>A query for matching tasks.</returns>
    public IQueryable<Task> ActiveForClass(int classId)
    {
        return from task in db.Tasks
               where task.ClassId == classId
               where task.DueDate > DateTime.Now
               select task;
    }

    /// <summary>
    /// Removes all tasks assigned to a class.
    /// </summary>
    /// <param name="classId">The class id.</param>
    public void RemoveForClass(int classId)
    {
        IQueryable<Task> tasks = ForClass(classId);
        db.Tasks.RemoveRange(tasks);
    }

    /// <summary>
    /// Removes all tasks assigned using a deck.
    /// </summary>
    /// <param name="deckId">The deck id.</param>
    public void RemoveForDeck(int deckId)
    {
        IQueryable<Task> tasks = ForDeck(deckId);
        db.Tasks.RemoveRange(tasks);
    }
}