using System;
namespace Languages.ApiModels;

public class TaskSummaryVm
{
    public TaskVm TaskDetails { get; set; }
    public List<StudentProgress> Students { get; set; }
}

