using Languages.DbModels;
using Task = Languages.DbModels.Task;

namespace Languages.ApiModels;

public class TeacherSummaryVm
{
    public List<ClassVm> Classes { get; set; }
    public List<Task> Tasks { get; set; }
    public List<Deck> Decks { get; set; }
}