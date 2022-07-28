namespace Languages.ApiModels;

public class TaskCardVm
{
    public int CardId { get; set; }
    public string EnglishTerm { get; set; }
    public string ForeignTerm { get; set; }
    public DateTime DueDate { get; set; }
    public int LastQuestionType { get; set; }
}