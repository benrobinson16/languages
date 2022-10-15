using Microsoft.EntityFrameworkCore;
using Languages.DbModels;
using Task = Languages.DbModels.Task;

namespace Languages.Services;

public class DatabaseContext : DbContext
{
    public DatabaseContext() : base() { }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        string connectionString = "server=languages-database.cozrjn0fmjmy.eu-west-2.rds.amazonaws.com; port=3306; database=Languages; user=admin; password=SV30XOV9OBc3PofJcwie";
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
