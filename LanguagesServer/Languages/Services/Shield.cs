using Languages.DbModels;
using Languages.ApiModels;

namespace Languages.Services;

public class Shield
{
    DatabaseAccess da;
    Authenticator auth;

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

    public async Task<Student> AuthenticateStudent(HttpRequest request)
    {
        User user = Authenticate(request);

        Student? student = await da.Students.ByEmail(user.Email);
        if (student == null) throw new LanguagesUnauthorized();

        return student;
    }

    public async Task<Teacher> AuthenticateTeacher(HttpRequest request)
    {
        User user = Authenticate(request);

        Teacher? teacher = await da.Teachers.ByEmail(user.Email);
        if (teacher == null) throw new LanguagesUnauthorized();

        return teacher;
    }
}
