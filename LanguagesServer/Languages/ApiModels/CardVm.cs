namespace Languages.ApiModels;

public class CardVm
{
    public int CardId { get; set; }
    public string EnglishTerm { get; set; }
    public string ForeignTerm { get; set; }
    public DateTime? DueDate { get; set; }
    public QuestionType? NextQuestionType { get; set; }
}