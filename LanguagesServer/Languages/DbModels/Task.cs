using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class Task
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int TaskId { get; set; }

    public DateTime DueDate { get; set; }
    public DateTime SetDate { get; set; }
    public int DeckId { get; set; }
    public int ClassId { get; set; }
}

