import SwiftUI

struct PracticeFlashcardsView: View {
    @EnvironmentObject var store: FlashcardsStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0
    @State private var showBack: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Öva flashcards").font(.title)

            if store.cards.isEmpty {
                Text("Inga kort ännu. Gå till Skapa och lägg till några!")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                let card = store.cards[currentIndex]

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.mint.opacity(0.2))
                        .frame(height: 220)
                        .padding(.horizontal)

                    Text(showBack ? card.back : card.front)
                        .font(.title2)
                        .padding()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .onTapGesture {
                    withAnimation { showBack.toggle() }
                }

                HStack {
                    Button("Föregående") {
                        guard !store.cards.isEmpty else { return }
                        currentIndex = (currentIndex - 1 + store.cards.count) % store.cards.count
                        showBack = false
                    }
                    .buttonStyle(.bordered)

                    Button("Nästa") {
                        guard !store.cards.isEmpty else { return }
                        currentIndex = (currentIndex + 1) % store.cards.count
                        showBack = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .navigationTitle("Öva")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Klar", action: { dismiss() })
            }
        }
    }
}

#Preview {
    PracticeFlashcardsView().environmentObject(FlashcardsStore())
}
