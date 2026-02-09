import SwiftUI

struct FlashcardsView: View {
    let folder: Folder
    @State private var cards: [Flashcard] = []
    @State private var question: String = ""
    @State private var answer: String = ""
    private let store = FlashcardStore()
    
    var body: some View {
        List {
            Section("Ny flashcard") {
                TextField("Text 1, t.ex. en fråga", text: $question)
                TextField("Text 2, t.ex. ett svar", text: $answer)
                Button("Lägg till") {
                    let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
                    let a = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !q.isEmpty else { return }
                    cards.append(Flashcard(question: q, answer: a))
                    store.save(cards, for: folder.id)
                    question = ""
                    answer = ""
                }
            }
            
            Section("Skapade flashcards") {
                if cards.isEmpty {
                    ContentUnavailableView("Här var det tomt", systemImage: "rectangle.stack.badge.plus", description: Text("Skapa kort ovan."))
                } else {
                    ForEach(cards) { card in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.question)
                                .font(.headline)
                            Text(card.answer)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        cards.remove(atOffsets: offsets)
                        store.save(cards, for: folder.id)
                    }
                }
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { cards = store.load(for: folder.id) }
    }
}

struct FlashcardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FlashcardsView(folder: Folder(title: "Biologi", description: "Kapitel 3"))
        }
    }
}
