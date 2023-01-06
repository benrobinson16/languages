import Foundation

let studentUrl = URL(string: "https://api.languages.benrobinson.dev/student")!
let accountUrl = URL(string: "https://api.languages.benrobinson.dev/account/student")!

extension Request {
    public static func register(token: String) -> Request<Bool> {
        print(token)
        
        return .init(
            method: .post,
            url: accountUrl.appending(path: "register"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func summary(token: String) -> Request<StudentSummary> {
        print(token)
        return .init(
            method: .get,
            url: studentUrl.appending(path: "summary"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func taskCards(token: String) -> Request<[Card]> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "taskcards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func reviewCards(token: String) -> Request<[Card]> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "reviewCards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func taskDetails(id: Int, token: String) -> Request<TaskSummary> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "taskDetails"),
            headers: ["Authorization": token],
            data: ["taskId": String(id)]
        )
    }
    
    public static func didAnswer(cardId: Int, correct: Bool, questionType: QuestionType, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "didanswer"),
            headers: ["Authorization": token],
            data: ["cardId": String(cardId), "correct": String(correct), "questionType": String(questionType.rawValue)]
        )
    }
    
    public static func joinClass(joinCode: String, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "joinclass"),
            headers: ["Authorization": token],
            data: ["joinCode": joinCode]
        )
    }
    
    public static func leaveClass(classId: Int, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "leaveclass"),
            headers: ["Authorization": token],
            data: ["classId": String(classId)]
        )
    }
    
    public static func registerDevice(device: String, token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "registerDevice"),
            headers: ["Authorization": token],
            data: ["token": device]
        )
    }
    
    public static func removeRegisteredDevice(token: String) -> Request<StatusResponse> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "removeDevice"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func distractors(cardId: Int, token: String) -> Request<[String]> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "distractors"),
            headers: ["Authorization": token],
            data: ["cardId": String(cardId)]
        )
    }
    
    public static func dailyCompletion(token: String) -> Request<Double> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "dailyCompletion"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func settingsSummary(token: String) -> Request<SettingsSummary> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "settingsSummary"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func updateNotificationSettings(time: Date, enabled: Bool, token: String) -> Request<StatusResponse> {
        return .init(
            method: .patch,
            url: studentUrl.appending(path: "updateNotificationSettings"),
            headers: ["Authorization": token],
            data: ["time": time.ISO8601Format(), "enabled": String(enabled)]
        )
    }
}
