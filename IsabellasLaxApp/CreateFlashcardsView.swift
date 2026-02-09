import SwiftUI

struct CreateFlashcardsView: View {
    @EnvironmentObject var store: FlashcardsStore
    @State private var frontText: String = ""
    @State private var backText: String = ""

    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 16) {
            TextField("Framsida - t.ex. Frågan", text: $frontText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top)

            TextField("Baksida - t.ex. Svaret", text: $backText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button {
                let f = frontText.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = backText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !f.isEmpty, !b.isEmpty else { return }
                store.add(front: f, back: b)
                frontText = ""
                backText = ""
            } label: {
                Text("Spara")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Divider().padding(.horizontal)

            // Synlig lista över sparade ord
            if store.cards.isEmpty {
                Text("Inget sparat ännu")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                List(store.cards) { card in
                    HStack(alignment: .firstTextBaseline) {
                        Text(card.front)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(card.back)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .navigationTitle("Skapa flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CreateFlashcardsView().environmentObject(FlashcardsStore())
}
