using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Services;

/// <summary>
/// Responsible for validating JWTs via Authenticator and then checking
/// for existance in the database and throwing errors to revoke access
/// to the method if not.
/// </summary>
public class Shield
{
    private DatabaseAccess da;
    private Authenticator auth;

    public Shield(DatabaseAccess da, Authenticator auth)
    {
        this.da = da;
        this.auth = auth;
    }

    /// <summary>
    /// Authenticates an unregistered user.
    /// </summary>
    /// <param name="request">The HTTP request.</param>
    /// <returns>The user object from the provided authorization.</returns>
    /// <exception cref="LanguagesUnauthenticated">The JWT is invalid.</exception>
    public User Authenticate(HttpRequest request)
    {
        string token = request.Headers["Authorization"];
        if (token == null) throw new LanguagesUnauthenticated();

        User? user = auth.Authenticate(token);
        if (user == null) throw new LanguagesUnauthenticated();

        return user;
    }

    /// <summary>
    /// Authenticates a student (cross-checking with the database).
    /// </summary>
    /// <param name="request">The HTTP request.</param>
    /// <returns>The student object from the database.</returns>
    /// <exception cref="LanguagesUnauthorized">
    /// The JWT is invalid or the student is not registered.
    /// </exception>
    public Student AuthenticateStudent(HttpRequest request)
    {
        User user = Authenticate(request);

        Student? student = da.Students.ForEmail(user.Email).SingleOrDefault();
        if (student == null) throw new LanguagesUnauthorized();

        return student;
    }

    /// <summary>
    /// Authenticates a teacher (cross-checking with the database).
    /// </summary>
    /// <param name="request">The HTTP request.</param>
    /// <returns>The teacher object from the database.</returns>
    /// <exception cref="LanguagesUnauthorized">
    /// The JWT is invalid or the teacher is not registered.
    /// </exception>
    public Teacher AuthenticateTeacher(HttpRequest request)
    {
        User user = Authenticate(request);

        Teacher? teacher = da.Teachers.ForEmail(user.Email).SingleOrDefault();
        if (teacher == null) throw new LanguagesUnauthorized();

        return teacher;
    }
}
