﻿using Microsoft.EntityFrameworkCore;
using Languages.Models;
using Task = Languages.Models.Task;

namespace Languages.Services;

public class DatabaseContext : DbContext
{
    private readonly IConfiguration Configuration;

    public DatabaseContext(IConfiguration configuration) : base()
    {
        Configuration = configuration;
    }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        var connectionString = Configuration.GetConnectionString("LocalConnection");
        options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Explicitly define the composite keys as this is not supported via annotations.
        modelBuilder.Entity<StudentAttempt>().HasKey("StudentId", "CardId", "AttemptDate");
        modelBuilder.Entity<Enrollment>().HasKey("StudentId", "ClassId");

        // Declare the name of each table.
        modelBuilder.Entity<Student>().ToTable("Student");
        modelBuilder.Entity<Teacher>().ToTable("Teacher");
        modelBuilder.Entity<Enrollment>().ToTable("Enrollment");
        modelBuilder.Entity<Class>().ToTable("Class");
        modelBuilder.Entity<Task>().ToTable("Task");
        modelBuilder.Entity<Deck>().ToTable("Deck");
        modelBuilder.Entity<Card>().ToTable("Card");
        modelBuilder.Entity<StudentAttempt>().ToTable("StudentAttempt");
    }

    public DbSet<Student> Students { get; set; }
    public DbSet<Teacher> Teachers { get; set; }
    public DbSet<Enrollment> Enrollments { get; set; }
    public DbSet<Class> Classes { get; set; }
    public DbSet<Task> Tasks { get; set; }
    public DbSet<Deck> Decks { get; set; }
    public DbSet<Card> Cards { get; set; }
    public DbSet<StudentAttempt> StudentAttempts { get; set; }
}