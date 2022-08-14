﻿using System;
using Languages.ApiModels;
using Languages.DbModels;

namespace Languages.Services.Repositories;

public class StudentAttemptRepository
{
    DatabaseContext db;

    public StudentAttemptRepository(DatabaseContext db)
    {
        this.db = db;
    }

    public IQueryable<StudentProgress> ProgressForTask2(int deckId, int classId)
    {
        List<Card> cards = (from card in db.Cards
                            where card.DeckId == deckId
                            select card).ToList();

        int expectedQuestions = cards.Count() * (int)QuestionType.ForeignWritten;

        return from enrol in db.Enrollments
               where enrol.ClassId == classId
               join student in db.Students on enrol.StudentId equals student.StudentId
               let numCompleted = (
                   from card in cards
                   let latestAttempt = (
                       from attempt in db.StudentAttempts
                       where attempt.StudentId == student.StudentId
                       where attempt.CardId == card.CardId
                       orderby attempt.AttemptDate descending
                       select attempt
                   ).First()
                   select latestAttempt == null ? 0 : (
                       latestAttempt.Correct ?
                       latestAttempt.QuestionType :
                       Math.Max(latestAttempt.QuestionType - 1, 0)
                   )
               ).Sum()
               select new StudentProgress
               {
                   StudentId = student.StudentId,
                   Name = student.DisplayName,
                   Email = student.Email,
                   Progress = expectedQuestions == 0 ? 100 : (int)Math.Floor(100.0 * numCompleted / expectedQuestions)
               };
    }

    // This method returns a list rather than an IQueryable conforming type because it requires client-side
    // computation in addition to the commands performed by SQL server. This is due to issues with the EFCore
    // framework translating LINQ query syntax to SQL for queries involving outer joins/group by statements.
    public List<StudentProgress> ProgressForTask(int deckId, int classId)
    {
        List<Card> cards = (from card in db.Cards
                            where card.DeckId == deckId
                            select card).ToList();

        int expectedQuestions = cards.Count() * (int)QuestionType.ForeignWritten;

        List<Student> students = (from enrol in db.Enrollments
                                  where enrol.ClassId == classId
                                  join student in db.Students on enrol.StudentId equals student.StudentId
                                  select student).ToList();

        List<StudentProgress> progresses = new List<StudentProgress>();
        foreach (Student student in students)
        {
            int numCompleted = 0;

            foreach (Card card in cards)
            {
                StudentAttempt? latestAttempt = (from attempt in db.StudentAttempts
                                                 where attempt.StudentId == student.StudentId
                                                 where attempt.CardId == card.CardId
                                                 orderby attempt.AttemptDate descending
                                                 select attempt).FirstOrDefault();

                if (latestAttempt == null)
                {
                    numCompleted += 0;
                }
                else if (latestAttempt.Correct)
                {
                    numCompleted += latestAttempt.QuestionType;
                }
                else
                {
                    numCompleted += Math.Max(latestAttempt.QuestionType - 1, 0);
                }
            }

            progresses.Add(new StudentProgress
            {
                StudentId = student.StudentId,
                Name = student.DisplayName,
                Email = student.Email,
                Progress = expectedQuestions == 0 ? 100 : (int)Math.Floor(100.0 * numCompleted / expectedQuestions)
            });
        }

        return progresses;
    }
}

