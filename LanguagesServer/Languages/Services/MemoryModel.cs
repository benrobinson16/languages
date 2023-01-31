using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services;

public class MemoryModel
{
    DatabaseAccess da;

    // Constant weights
    double difficultyWeight = 1.0;
    double dailyPenalty = 0.05;

    public MemoryModel(DatabaseAccess da)
    {
        this.da = da;
    }

    public List<CardVm> NextCardsToReview(int studentId, int sampleSize = 100, int outputSize = 10)
    {
        List<Card> cardSample = da.Cards
            .RandomSampleForStudent(studentId)
            .Take(sampleSize)
            .ToList();

        List<(Card, double)> cardModelPairs = new List<(Card, double)>();
        foreach (Card card in cardSample)
        {
            double modelVal = ModelCard(card, studentId);
            cardModelPairs.Add((card, modelVal));
        }

        return cardModelPairs
            .OrderBy(pair => pair.Item2)
            .Take(outputSize)
            .Select(pair => pair.Item1)
            .Select(c => new CardVm
            {
                CardId = c.CardId,
                DueDate = null,
                NextQuestionType = null,
                EnglishTerm = c.EnglishTerm,
                ForeignTerm = c.ForeignTerm
            })
            .ToList();
    }

    public double ModelCard(Card card, int studentId)
    {
        double summation = -card.Difficulty * difficultyWeight;

        int? daysSinceAttempt = da.StudentAttempts.DaysSinceAttempt(card.CardId, studentId);
        if (daysSinceAttempt != null && daysSinceAttempt < 60)
        {
            summation -= dailyPenalty * (int)daysSinceAttempt;
        }
        else
        {
            summation -= dailyPenalty * 60;
        }

        foreach (TimeWindow window in GetTimeWindows(DateTime.Now))
        {
            int numCorrect = da.StudentAttempts.CorrectAttemptsInWindow(studentId, card.CardId, window.Start, window.End).Count();
            int numTotal = da.StudentAttempts.AttemptsInWindow(studentId, card.CardId, window.Start, window.End).Count();
            int numIncorrect = numTotal - numCorrect;
            summation += (window.CorrectWeight * numCorrect) - (window.IncorrectWeight * numIncorrect);
        }

        // We divide the summation by 20 to get roughly reasonable values out.
        // This does not impact the functioning of the algorithm since the cards
        // are just ordered in terms of their modelled prob(success) - not the
        // absolute values.
        return Logistic(summation / 20.0);
    }

    private double Logistic(double z)
    {
        return 1.0 / (1 + Math.Exp(-z));
    }

    private List<TimeWindow> GetTimeWindows(DateTime startDate)
    {
        DateTime d1 = startDate.Date.AddDays(-1);
        DateTime d2 = startDate.Date.AddDays(-7);
        DateTime d3 = startDate.Date.AddDays(-30);
        DateTime d4 = startDate.Date.AddDays(-120);
        DateTime d5 = startDate.Date.AddDays(-360);

        return new List<TimeWindow>
        {
            new TimeWindow { Start = d5, End = d4, CorrectWeight = 1, IncorrectWeight = 2 },
            new TimeWindow { Start = d4, End = d3, CorrectWeight = 2, IncorrectWeight = 4 },
            new TimeWindow { Start = d3, End = d2, CorrectWeight = 4, IncorrectWeight = 8 },
            new TimeWindow { Start = d2, End = d1, CorrectWeight = 8, IncorrectWeight = 16 },
            new TimeWindow { Start = d1, End = startDate, CorrectWeight = 16, IncorrectWeight = 32 },
        };
    }

    private class TimeWindow
    {
        public DateTime Start { get; set; }
        public DateTime End { get; set; }
        public double CorrectWeight { get; set; }
        public double IncorrectWeight { get; set; }
    }
}