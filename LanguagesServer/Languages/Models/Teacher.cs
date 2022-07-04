using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.Models;

public class Teacher
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int TeacherId { get; set; }

    public string Title { get; set; }
    public string Surname { get; set; }
    public string Email { get; set; }

    public string DisplayName => Title + " " + Surname;
}

