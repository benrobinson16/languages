using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services;

public class MemoryModel
{
    DatabaseAccess da;
    DatabaseContext db;

    // Constant weights
    const double kDifficulty = 1.0;
    const double kAttemptBase = 1.05;
    const double kNoReview = 0.3;
    const double kScale = 0.5;

    public MemoryModel(DatabaseAccess da, DatabaseContext db)
    {
        this.da = da;
        this.db = db;
    }

    public List<CardVm> NextCardsToReview(int studentId, int sampleSize = 100, int outputSize = 10)
    {
        List<Card> cardSample = da.Cards
            .RandomSampleForStudent(studentId)
            .DistinctBy(c => c.CardId)
            .Take(sampleSize)
            .ToList();

        List<(Card, double)> cardModelPairs = new List<(Card, double)>();
        foreach (Card card in cardSample)
        {
            double modelVal = ModelCard(card, studentId);
            cardModelPairs.Add((card, modelVal));
        }

        if (cardModelPairs.Count() > 10)
        {
            cardModelPairs = cardModelPairs
                .OrderBy(pair => pair.Item2)
                .Take(outputSize)
                .ToList();
        }

        return cardModelPairs
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
        double summation = 0.0;

        // Get a list of attempts for the algorithm to
        List<StudentAttempt> attempts = da.StudentAttempts
            .StudentAttemptsForCard(studentId, card.CardId)
            .ToList();

        // Adjust by the weight of each attempt
        foreach (StudentAttempt attempt in attempts)
        {
            summation += AttemptWeighting(attempt.AttemptDate, attempt.Correct);
        }

        // Adjust by the time since the card was last reviewed
        StudentAttempt? mostRecent = attempts.MaxBy(a => a.AttemptDate);
        if (mostRecent != null)
        {
            summation += NoReviewPenalty(mostRecent.AttemptDate);
        }

        // Adjust by the difficulty rating
        summation += (1 - card.Difficulty) * kDifficulty;

        // Convert to a percentage [0, 1]
        return Logistic(summation / kScale);
    }

    private double AttemptWeighting(DateTime attemptDate, bool correct)
    {
        int days = (DateTime.Now - attemptDate).Days;
        return (correct ? 1 : -1) * Math.Pow(kAttemptBase, -(0.5 * days));
    }

    private double NoReviewPenalty(DateTime lastReview)
    {
        int days = (DateTime.Now - lastReview).Days;
        return -kNoReview * Math.Log2((0.5 * days) + 1);
    }

    private double Logistic(double z)
    {
        return 1.0 / (1 + Math.Exp(-z));
    }
}