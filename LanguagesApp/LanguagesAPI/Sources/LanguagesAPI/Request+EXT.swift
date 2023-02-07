import Foundation

extension Request {
    private static var studentUrl: URL {
        return URL(string: "https://api.languages.benrobinson.dev/student")!
    }
    
    private static var accountUrl: URL {
        return URL(string: "https://api.languages.benrobinson.dev/account/student")!
    }
    
    /// Registers a student with the server.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: Whether or not the student is new to the platform.
    public static func register(token: String) -> Request<Bool> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "register"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Gets summary/home screen information for a user.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: A request for the summary data.
    public static func summary(token: String) -> Request<StudentSummary> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "summary"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Gets a list of cards, to be inserted into an LQN.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: A request for the cards.
    public static func taskCards(token: String) -> Request<[Card]> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "taskcards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Gets a list of cards, to be answered in review mode.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: A request for the cards.
    public static func reviewCards(token: String) -> Request<[Card]> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "reviewCards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Gets information about a task, such as completion, due date and the cards involved.
    /// - Parameters:
    ///   - id: The id of the task.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request for the task information.
    public static func taskDetails(id: Int, token: String) -> Request<TaskSummary> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "taskDetails"),
            headers: ["Authorization": token],
            data: ["taskId": String(id)]
        )
    }
    
    /// Informs the server of the student answering a card.
    /// - Parameters:
    ///   - cardId: The id of the card that was answered.
    ///   - correct: Whether or not the student correctly answered.
    ///   - questionType: The type of question that was answered.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request that sends this data to the server and returns a ``StatusResponse`` indicating success or failure.
    public static func didAnswer(cardId: Int, correct: Bool, questionType: QuestionType, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "didanswer"),
            headers: ["Authorization": token],
            data: ["cardId": String(cardId), "correct": String(correct), "questionType": String(questionType.rawValue)]
        )
    }
    
    /// Adds the student to a class using its join code.
    /// - Parameters:
    ///   - joinCode: The join code of the class to join.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request that joins the student to the class. If the join code is invalid, an error message may be returned in the ``StatusResponse``.
    public static func joinClass(joinCode: String, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "joinclass"),
            headers: ["Authorization": token],
            data: ["joinCode": joinCode]
        )
    }
    
    /// Removes a student from a class.
    /// - Parameters:
    ///   - classId: The id of the class to leave. This must be id not join code.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request to the server to leave the class. If the class id is invalid, an error message may be returned in the ``StatusResponse``.
    public static func leaveClass(classId: Int, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "leaveclass"),
            headers: ["Authorization": token],
            data: ["classId": String(classId)]
        )
    }
    
    /// Adds a device registration to allow push notifications to this device.
    /// - Parameters:
    ///   - device: The Apple-provided device token that uniquely identifies this device.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request to add this device.
    public static func registerDevice(device: String, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "registerDevice"),
            headers: ["Authorization": token],
            data: ["token": device]
        )
    }
    
    /// Removes a device registration to stop push notifications to this device. For example, on sign out.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: A request to remove this device.
    public static func removeRegisteredDevice(token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "removeDevice"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Gets a list of 3 distractors for multiple choice questions, responding in a foreign languge.
    /// - Parameters:
    ///   - cardId: The id of the card to obtain distractor responses for.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request for the 3 distractors.
    public static func distractors(cardId: Int, token: String) -> Request<[String]> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "distractors"),
            headers: ["Authorization": token],
            data: ["cardId": String(cardId)]
        )
    }
    
    /// Gets the user's current estimated percentage through today's work.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: A request for the percentage (in range 0...1).
    public static func dailyCompletion(token: String) -> Request<Double> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "dailyCompletion"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Gets details about the user's current settings configuration, such as account and notifications.
    /// - Parameter token: A Microsoft OAuth token.
    /// - Returns: A request for the settings data.
    public static func settingsSummary(token: String) -> Request<SettingsSummary> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "settingsSummary"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    /// Updates a user's daily reminder notification settings on the server.
    /// - Parameters:
    ///   - time: The time of the reminder notification. The date component will be ignored.
    ///   - enabled: Whether the daily reminder notifications should be enabled.
    ///   - token: A Microsoft OAuth token.
    /// - Returns: A request to send this data to the server.
    public static func updateNotificationSettings(time: Date, enabled: Bool, token: String) -> Request<StatusResponse> {
        return .init(
            method: .patch,
            url: studentUrl.appending(path: "updateNotificationSettings"),
            headers: ["Authorization": token],
            data: ["time": time.ISO8601Format(), "enabled": String(enabled)]
        )
    }
}
