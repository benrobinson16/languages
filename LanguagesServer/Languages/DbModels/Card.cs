using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class Card
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int CardId { get; set; }

    public string EnglishTerm { get; set; }
    public string ForeignTerm { get; set; }
    public double Difficulty { get; set; }
    public int DeckId { get; set; }
}
