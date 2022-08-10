using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Languages.DbModels;

public class Student
{
	[Key]
	[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
	public int StudentId { get; set; }

	public string FirstName { get; set; }
	public string Surname { get; set; }
	public string Email { get; set; }
	public string? DeviceToken { get; set; }

	public string DisplayName => FirstName + " " + Surname;
}