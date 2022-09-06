namespace Languages.ApiModels;

public class TeacherTaskSummaryVm
{
    public TaskVm TaskDetails { get; set; }
    public List<StudentProgress> Students { get; set; }
}
