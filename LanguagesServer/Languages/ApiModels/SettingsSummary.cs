namespace Languages.ApiModels;

public class SettingsSummary
{
    public string Name { get; set; }
    public string Email { get; set; }
    public DateTime? ReminderTime { get; set; }
    public bool DailyReminderEnabled { get; set; }
}