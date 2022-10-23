import Foundation

let studentUrl = URL(string: "https://api.languages.benrobinson.dev/student")!
let accountUrl = URL(string: "https://api.languages.benrobinson.dev/account")!

extension Request {
    public static func isNewStudent(token: String) -> Request<Bool> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "student/isNewStudent"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func summary(token: String) -> Request<StudentSummary> {
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
            url: studentUrl.appending(path: "taskcards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    public static func taskDetails(id: Int, token: String) -> Request<TaskSummary> {
        return .init(
            method: .get,
            url: studentUrl.appending(path: "taskSummary"),
            headers: ["Authorization": token],
            data: ["taskId": String(id)]
        )
    }
    
    public static func didAnswer(cardId: Int, correct: Bool, questionType: QuestionType, token: String) -> Request<Int> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "didanswer"),
            headers: ["Authorization": token],
            data: ["cardId": String(cardId), "correct": String(correct), "questionType": String(questionType.rawValue)]
        )
    }
    
    public static func joinClass(joinCode: String, token: String) -> Request<Int> {
        return .init(
            method: .post,
            url: studentUrl.appending(path: "joinclass"),
            headers: ["Authorization": token],
            data: ["joinCode": joinCode]
        )
    }
    
    public static func registerDevice(device: String, token: String) -> Request<String> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "registerDevice"),
            headers: ["Authorization": token],
            data: ["token": device]
        )
    }
    
    public static func removeRegisteredDevice(token: String) -> Request<String> {
        return .init(
            method: .post,
            url: accountUrl.appending(path: "removeDevice"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
}
