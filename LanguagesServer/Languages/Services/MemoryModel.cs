using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services;

public class MemoryModel
{
    DatabaseAccess da;
    DatabaseContext db;

    // Constant weights
    const double difficultyWeight = 15.0;
    const double dailyPenaltyWeight = 1;
    const double bias = 5.0;

    public MemoryModel(DatabaseAccess da, DatabaseContext db)
    {
        this.da = da;
        this.db = db;
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

    const double attemptWeightBase = 1.05;
    const double noReviewPenaltyWeight = 0.3;
    const double logisticScale = 0.5;

    public double ModelCard(Card card, int studentId)
    {
        double summation = 0.0;

        List<StudentAttempt> attempts = db.StudentAttempts.Where(s => s.StudentId == studentId && s.CardId == card.CardId).ToList();
        foreach (StudentAttempt attempt in attempts)
        {
            int days = (DateTime.Now - attempt.AttemptDate).Days;
            summation = summation + (attempt.Correct ? 1 : -1) * Math.Pow(attemptWeightBase, -days);
        }

        StudentAttempt? mostRecent = attempts.MaxBy(a => a.AttemptDate);
        if (mostRecent != null)
        {
            int days = (DateTime.Now - mostRecent.AttemptDate).Days;
            summation -= noReviewPenaltyWeight * Math.Log2(days + 1);
        }

        return Logistic(summation / logisticScale);
    }

    public double ModelCard2(Card card, int studentId)
    {
        double summation = 0.0;
        summation += bias;
        summation -= card.Difficulty * difficultyWeight;

        int? daysSinceAttempt = da.StudentAttempts.DaysSinceAttempt(card.CardId, studentId);
        if (daysSinceAttempt != null && daysSinceAttempt >= 1)
        {
            summation -= Math.Log((double)daysSinceAttempt);
        }

        foreach (TimeWindow window in GetTimeWindows(DateTime.Now))
        {
            int numCorrect = da.StudentAttempts.CorrectAttemptsInWindow(studentId, card.CardId, window.Start, window.End).Count();
            int numTotal = da.StudentAttempts.AttemptsInWindow(studentId, card.CardId, window.Start, window.End).Count();
            int numIncorrect = numTotal - numCorrect;
            summation += (window.CorrectWeight * numCorrect) - (window.IncorrectWeight * numIncorrect);
        }

        // We divide the summation by 3 to get roughly reasonable values out.
        // This does not impact the functioning of the algorithm since the cards
        // are just ordered in terms of their modelled prob(success) - not the
        // absolute values.
        return Logistic(summation / 3.0);
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
            new TimeWindow { Start = d4, End = d3, CorrectWeight = 2, IncorrectWeight = 3 },
            new TimeWindow { Start = d3, End = d1, CorrectWeight = 3, IncorrectWeight = 4 },
            new TimeWindow { Start = d2, End = d1, CorrectWeight = 4, IncorrectWeight = 5 },
            new TimeWindow { Start = d1, End = startDate, CorrectWeight = 5, IncorrectWeight = 6 },
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