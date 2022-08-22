using Languages.DbModels;

namespace Languages.ApiModels;

public class TeacherSummaryVm
{
    public List<ClassVm> Classes { get; set; }
    public List<TaskVm> Tasks { get; set; }
    public List<DeckVm> Decks { get; set; }
}