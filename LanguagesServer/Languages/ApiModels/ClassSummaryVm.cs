using Task = Languages.DbModels.Task;

namespace Languages.ApiModels;

public class ClassSummaryVm
{
    public ClassVm ClassDetails { get; set; }
    public List<Task> Tasks { get; set; }
    public List<string> Students { get; set; }
}