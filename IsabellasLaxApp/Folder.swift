import Foundation

struct Folder: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date?

    init(id: UUID = UUID(), title: String, description: String, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
    }
}
