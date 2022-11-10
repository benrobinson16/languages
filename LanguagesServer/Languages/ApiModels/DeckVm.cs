namespace Languages.ApiModels;

public class DeckVm
{
    public int DeckId { get; set; }
    public string Name { get; set; }
    public int NumCards { get; set; }
    public DateTime CreationDate { get; set; }
}