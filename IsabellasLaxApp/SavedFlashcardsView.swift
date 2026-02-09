import SwiftUI
import Foundation

struct SavedFlashcardsView: View {
    var folder: Folder
    private let store = FlashcardStore()
    @State private var cards: [Flashcard] = []
    @Environment(\.editMode) private var editMode

    var body: some View {
        List {
            if cards.isEmpty {
                ContentUnavailableView("Inget sparat ännu", systemImage: "tray")
            } else {
                Section(header: Text("Sparade kort").font(.headline)) {
                    if editMode?.wrappedValue.isEditing == true {
                        ForEach($cards) { $card in
                            HStack(spacing: 12) {
                                TextField("Fråga...", text: $card.question)
                                    .textFieldStyle(.roundedBorder)
                                TextField("Svar...", text: $card.answer)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            cards.remove(atOffsets: indexSet)
                            let cleaned = cards.filter { !$0.question.isEmpty && !$0.answer.isEmpty }
                            store.save(cleaned, for: folder.id)
                            cards = cleaned
                        }
                    } else {
                        ForEach(cards) { card in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(card.question)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(card.answer)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
        .navigationTitle("Sparat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { EditButton() }
        }
        .onAppear { load() }
        .onDisappear { save() }
    }

    private func load() {
        cards = store.load(for: folder.id)
    }

    private func save() {
        let cleaned = cards.map { c in
            var c = c
            c.question = c.question.trimmingCharacters(in: .whitespacesAndNewlines)
            c.answer = c.answer.trimmingCharacters(in: .whitespacesAndNewlines)
            return c
        }.filter { !$0.question.isEmpty && !$0.answer.isEmpty }
        store.save(cleaned, for: folder.id)
        cards = cleaned
    }
}
