using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class Enrollment
{
    public int StudentId { get; set; }
    public int ClassId { get; set; }
}

