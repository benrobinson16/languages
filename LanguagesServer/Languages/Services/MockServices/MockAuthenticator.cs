using System;
using Languages.ApiModels;

namespace Languages.Services.MockServices;

public class MockAuthenticator : Authenticator
{
    private User? mockUser;

    public MockAuthenticator(User? mockUser) : base()
    {
        this.mockUser = mockUser;
    }

    public new User? Authenticate(string bearerToken)
    {
        return this.mockUser;
    }
}