import SwiftUI
import Foundation

struct FlashcardsEditorView: View {
    var folder: Folder
    private let store = FlashcardStore()

    @State private var cards: [Flashcard] = []
    @State private var goToSaved = false

    @State private var newQuestion: String = ""
    @State private var newAnswer: String = ""
    @State private var showSavedBanner = false

    var body: some View {
        VStack(spacing: 0) {
            // Add new card section
            VStack(alignment: .leading, spacing: 8) {
                Text("Lägg till nytt kort").font(.headline)
                HStack(spacing: 12) {
                    TextField("Fråga...", text: $newQuestion)
                        .textFieldStyle(.roundedBorder)
                    TextField("Svar...", text: $newAnswer)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        addNewCard()
                    } label: {
                        Label("Spara", systemImage: "tray.and.arrow.down")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                if showSavedBanner {
                    Text("Sparat!")
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }
            }
            .padding([.horizontal, .top])

            Divider().padding(.vertical, 8)

            // Header row
            HStack {
                Text("Sparade kort").font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            List {
                ForEach(cards.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        TextField("Fråga...", text: $cards[index].question)
                            .textFieldStyle(.roundedBorder)
                        TextField("Svar...", text: $cards[index].answer)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    cards.remove(atOffsets: offsets)
                    store.save(cards.filter { !$0.question.isEmpty && !$0.answer.isEmpty }, for: folder.id)
                }
            }
            .listStyle(.plain)

            Divider()
            HStack {
                Spacer()
                Button {
                    saveAll()
                } label: {
                    Label("Spara ändringar", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(.bottom)
        }
        .navigationTitle("Spara glosor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadCards() }
    }

    private func loadCards() {
        cards = store.load(for: folder.id)
    }

    private func saveAll() {
        var cleaned = cards.map { card in
            var c = card
            c.question = c.question.trimmingCharacters(in: .whitespacesAndNewlines)
            c.answer = c.answer.trimmingCharacters(in: .whitespacesAndNewlines)
            return c
        }.filter { !$0.question.isEmpty || !$0.answer.isEmpty }
        if cleaned.isEmpty { cleaned = [Flashcard(question: "", answer: "")] }
        let toPersist = cleaned.filter { !$0.question.isEmpty && !$0.answer.isEmpty }
        store.save(toPersist, for: folder.id)
        cards = cleaned

        withAnimation { showSavedBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showSavedBanner = false }
        }
    }

    private func addNewCard() {
        let q = newQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = newAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !a.isEmpty else { return }
        var current = store.load(for: folder.id)
        current.append(Flashcard(question: q, answer: a))
        store.save(current, for: folder.id)
        cards = current
        newQuestion = ""
        newAnswer = ""
        withAnimation { showSavedBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showSavedBanner = false }
        }
    }
}
