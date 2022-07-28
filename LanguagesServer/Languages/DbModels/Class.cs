using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class Class
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int ClassId { get; set; }

    public string Name { get; set; }
    public string JoinCode { get; set; }
    public int TeacherId { get; set; }
}

