import Foundation

let baseUrl = URL(string: "http://localhost:7098/student")!

extension Request {
    static func summary(token: String) -> Request<StudentSummary> {
        return .init(
            method: .get,
            url: baseUrl.appending(path: "summary"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    static func taskCards(token: String) -> Request<[Card]> {
        return .init(
            method: .get,
            url: baseUrl.appending(path: "taskcards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    static func reviewCards(token: String) -> Request<[Card]> {
        return .init(
            method: .get,
            url: baseUrl.appending(path: "taskcards"),
            headers: ["Authorization": token],
            data: [:]
        )
    }
    
    static func taskDetails(id: Int, token: String) -> Request<TaskSummary> {
        return .init(
            method: .get,
            url: baseUrl.appending(path: "taskSummary"),
            headers: ["Authorization": token],
            data: ["taskId": String(id)]
        )
    }
    
    static func didAnswer(cardId: Int, correct: Bool, questionType: QuestionType, token: String) -> Request<Int> {
        return .init(
            method: .post,
            url: baseUrl.appending(path: "didanswer"),
            headers: ["Authorization": token],
            data: ["cardId": String(cardId), "correct": String(correct), "questionType": String(questionType.rawValue)]
        )
    }
    
    static func joinClass(joinCode: String, token: String) -> Request<Int> {
        return .init(
            method: .post,
            url: baseUrl.appending(path: "joinclass"),
            headers: ["Authorization": token],
            data: ["joinCode": joinCode]
        )
    }
}
