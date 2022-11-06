namespace Languages.ApiModels;

public class StudentSummaryVm
{
    public List<StreakDay> StreakHistory { get; set; }
    public int StreakLength { get; set; }
    public List<TaskVm> Tasks { get; set; }
    public List<EnrollmentVm> Enrollments { get; set; }
    public double DailyPercentage { get; set; }
    public string OverdueMessage { get; set; }
    public string StudentName { get; set; }
}