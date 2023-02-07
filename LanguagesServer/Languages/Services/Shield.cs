using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Services;

public class Shield
{
    private DatabaseAccess da;
    private Authenticator auth;

    public Shield(DatabaseAccess da, Authenticator auth)
    {
        this.da = da;
        this.auth = auth;
    }

    public User Authenticate(HttpRequest request)
    {
        string token = request.Headers["Authorization"];

        User? user = auth.Authenticate(token);
        if (user == null) throw new LanguagesUnauthenticated();

        return user;
    }

    public Student AuthenticateStudent(HttpRequest request)
    {
        User user = Authenticate(request);

        Student? student = da.Students.ForEmail(user.Email).SingleOrDefault();
        if (student == null) throw new LanguagesUnauthorized();

        return student;
    }

    public Teacher AuthenticateTeacher(HttpRequest request)
    {
        User user = Authenticate(request);

        Teacher? teacher = da.Teachers.ForEmail(user.Email).SingleOrDefault();
        if (teacher == null) throw new LanguagesUnauthorized();

        return teacher;
    }
}
