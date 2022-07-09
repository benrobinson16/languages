using Languages.Models;

namespace Languages.Services;

public class Shield
{
    DatabaseAccess da;
    Authenticator auth;

    public Shield(DatabaseAccess da)
    {
        this.da = da;
        this.auth = new Authenticator();
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
        Student? student = da.Students.ByEmail(user.Email);
        if (student == null) throw new LanguagesUnauthorized();
        return student;
    }

    public Teacher AuthenticateTeacher(HttpRequest request)
    {
        User user = Authenticate(request);
        Teacher? teacher = da.Teachers.ByEmail(user.Email);
        if (teacher == null) throw new LanguagesUnauthorized();
        return teacher;
    }
}
