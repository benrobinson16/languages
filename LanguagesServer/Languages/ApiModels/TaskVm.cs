namespace Languages.ApiModels;

public class TaskVm
{
    public int Id { get; set; }
    public int ClassId { get; set; }
    public int DeckId { get; set; }
    public string ClassName { get; set; }
    public string DeckName { get; set; }
    public string DueDate { get; set; }
}
