import SwiftUI
import Foundation

struct SavedFlashcardsView: View {
    var folder: Folder
    private let store = FlashcardStore()
    @State private var cards: [Flashcard] = []
    @Environment(\.editMode) private var editMode
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        List {
            if cards.isEmpty {
                ContentUnavailableView("Inget sparat ännu", systemImage: "tray")
            } else {
                if editMode?.wrappedValue.isEditing == true {
                    Section(header: Text("Sparade kort").font(.headline)) {
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
                    }
                } else {
                    Section(header: Text("Sparade kort").font(.headline)) {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                            ForEach(cards) { card in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.question)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                    Text(card.answer)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.gray.opacity(0.08))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.gray.opacity(0.25))
                                )
                            }
                        }
                        .padding(.vertical, 4)
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
