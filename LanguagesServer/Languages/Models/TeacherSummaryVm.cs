using System;

namespace Languages.Models;

public class TeacherSummaryVm
{
    public Teacher Teacher { get; set; }
    public List<Class> Classes { get; set; }
    public List<Task> Tasks { get; set; }
}