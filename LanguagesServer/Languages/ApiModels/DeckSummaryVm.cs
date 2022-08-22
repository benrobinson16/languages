using System;
using Languages.DbModels;

namespace Languages.ApiModels;

public class DeckSummaryVm
{
    public DeckVm DeckDetails { get; set; }
    public List<Card> Cards { get; set; }
}
