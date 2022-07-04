using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.Models;

public class Student
{
	[Key]
	[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
	public int StudentId { get; set; }

	public string FirstName { get; set; }
	public string Surname { get; set; }
	public string Email { get; set; }

	public virtual List<Enrollment> Enrollments { get; set; }
	public virtual List<StudentAttempt> StudentAttempts { get; set; }

	public string DisplayName => FirstName + " " + Surname;
}