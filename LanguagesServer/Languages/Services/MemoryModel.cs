using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services;

/// <summary>
/// Responsibel for modelling the probability of successful recall.
/// </summary>
public class MemoryModel
{
    private DatabaseAccess da;

    // Constant weights
    private const double kDifficulty = 1.0;
    private const double kAttemptBase = 1.05;
    private const double kNoReview = 0.3;
    private const double kScale = 0.5;

    public MemoryModel(DatabaseAccess da)
    {
        this.da = da;
    }

    /// <summary>
    /// Gets a list of cards to review next with the lowest
    /// modelled probability of successful recall.
    /// </summary>
    /// <param name="studentId">The student's id.</param>
    /// <param name="sampleSize">The number of random cards to model.</param>
    /// <param name="outputSize">The number of cards to output.</param>
    /// <returns>A list of cards to review next.</returns>
    public List<CardVm> NextCardsToReview(int studentId, int sampleSize = 100, int outputSize = 10)
    {
        List<Card> cardSample = da.Cards
            .RandomSampleForStudent(studentId)
            .Distinct()
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

    /// <summary>
    /// Gets the modelled probability of successful recall for a card.
    /// </summary>
    /// <param name="card">The card to model.</param>
    /// <param name="studentId">The student's id.</param>
    /// <returns></returns>
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

    /// <summary>
    /// Weight an attempt correct based on time of correct and
    /// whether or not it was correctly answered.
    /// </summary>
    /// <param name="attemptDate">When the attempt happened.</param>
    /// <param name="correct">Whether the attempt was correct.</param>
    /// <returns>The weighting for this attempt.</returns>
    private double AttemptWeighting(DateTime attemptDate, bool correct)
    {
        int days = (DateTime.Now - attemptDate).Days;
        return (correct ? 1 : -1) * Math.Pow(kAttemptBase, -(0.5 * days));
    }

    /// <summary>
    /// Calculates the penalty for not reviewing a term for
    /// any period of time.
    /// </summary>
    /// <param name="lastReview">The date of the last review.</param>
    /// <returns>The penalty to apply.</returns>
    private double NoReviewPenalty(DateTime lastReview)
    {
        int days = (DateTime.Now - lastReview).Days;
        return -kNoReview * Math.Log2((0.5 * days) + 1);
    }

    /// <summary>
    /// The logistic function. Applies upper and lower bounds
    /// of 1 and 0 and a smooth curve between them.
    /// </summary>
    /// <param name="z">The input value.</param>
    /// <returns>The logistic output.</returns>
    private double Logistic(double z)
    {
        return 1.0 / (1 + Math.Exp(-z));
    }
}