using System;

namespace Languages.Models;

public class TeacherSummaryVm
{
    public List<Class> Classes { get; set; }
    public List<Task> Tasks { get; set; }
    public List<Deck> Decks { get; set; }
}