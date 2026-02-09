import Foundation
import Combine

struct StudyFlashcard: Identifiable, Codable, Equatable {
    let id: UUID
    var front: String
    var back: String

    init(id: UUID = UUID(), front: String, back: String) {
        self.id = id
        self.front = front
        self.back = back
    }
}

final class FlashcardsStore: ObservableObject {
    @Published var cards: [StudyFlashcard] = [] {
        didSet { save() }
    }

    private let storageKey = "StudyFlashcards.storage"

    init() {
        load()
    }

    func add(front: String, back: String) {
        let card = StudyFlashcard(front: front, back: back)
        cards.append(card)
    }

    func delete(_ card: StudyFlashcard) {
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            cards.remove(at: idx)
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(cards)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // For a beginner app, we silently ignore errors
            #if DEBUG
            print("Failed to save flashcards:", error)
            #endif
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            cards = try JSONDecoder().decode([StudyFlashcard].self, from: data)
        } catch {
            #if DEBUG
            print("Failed to load flashcards:", error)
            #endif
            cards = []
        }
    }
}
