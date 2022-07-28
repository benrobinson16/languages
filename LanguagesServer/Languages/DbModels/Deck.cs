using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class Deck
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int DeckId { get; set; }

    public string Name { get; set; }
    public DateTime CreationDate { get; set; }
    public int TeacherId { get; set; }
}

