namespace Languages.ApiModels;

public class LanguagesUnauthenticated: Exception
{
    public LanguagesUnauthenticated() { }
}

public class LanguagesResourceNotFound: Exception
{
    public LanguagesResourceNotFound() { }
}

public class LanguagesUnauthorized: Exception
{
    public LanguagesUnauthorized() { }
}

public class LanguagesOperationAlreadyExecuted: Exception
{
    public LanguagesOperationAlreadyExecuted() { }
}

public class LanguagesInternalError : Exception
{
    public LanguagesInternalError() { }
}

public class LanguagesOperationNotCompleted : Exception
{
    public LanguagesOperationNotCompleted() { }
}