import Foundation
import Combine
import SwiftUI

struct Flashcard: Identifiable, Codable, Hashable {
    let id: UUID
    var question: String
    var answer: String
    init(id: UUID = UUID(), question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}

final class FlashcardStore: ObservableObject {
    private let keyPrefix = "flashcards_"

    private func key(for folderID: UUID) -> String { keyPrefix + folderID.uuidString }

    func load(for folderID: UUID) -> [Flashcard] {
        let key = key(for: folderID)
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([Flashcard].self, from: data)
        } catch {
            print("Kunde inte läsa flashcards: \(error)")
            return []
        }
    }

    func save(_ cards: [Flashcard], for folderID: UUID) {
        let key = key(for: folderID)
        do {
            let data = try JSONEncoder().encode(cards)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Kunde inte spara flashcards: \(error)")
        }
    }

    func add(question: String, answer: String, to folderID: UUID) {
        var cards = load(for: folderID)
        cards.append(Flashcard(question: question, answer: answer))
        save(cards, for: folderID)
    }

    func remove(at offsets: IndexSet, in folderID: UUID) {
        var cards = load(for: folderID)
        cards.remove(atOffsets: offsets)
        save(cards, for: folderID)
    }
}

