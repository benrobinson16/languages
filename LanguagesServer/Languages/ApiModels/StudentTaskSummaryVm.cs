using Languages.DbModels;

namespace Languages.ApiModels;

public class StudentTaskSummaryVm
{
    public TaskVm TaskDetails { get; set; }
    public List<Card> Cards { get; set; }
}