struct Message {
    let title: String
    let body: String
    let option1: MessageOption
    let option2: MessageOption?
}

struct MessageOption {
    let name: String
    let action: () -> Void
}
