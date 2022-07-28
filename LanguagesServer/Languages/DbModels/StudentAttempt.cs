using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class StudentAttempt
{
    public int StudentId { get; set; }
    public int CardId { get; set; }
    public DateTime AttemptDate { get; set; }
    public bool Correct { get; set; }
    public int QuestionType { get; set; }
}

