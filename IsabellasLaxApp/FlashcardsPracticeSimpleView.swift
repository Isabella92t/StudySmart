import SwiftUI
import Foundation

struct FlashcardsPracticeSimpleView: View {
    var folder: Folder
    private let store = FlashcardStore()

    @State private var cards: [Flashcard] = []
    @State private var currentIndex: Int = 0
    @State private var isAnswerShown: Bool = false
    @State private var showDoneOverlay: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if cards.isEmpty {
                ContentUnavailableView("Tomt", systemImage: "tray")
                    .padding(.top, 16)
            } else {
                Text("\(currentIndex + 1) / \(cards.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text(isAnswerShown ? cards[currentIndex].answer : cards[currentIndex].question)
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.gray.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.gray.opacity(0.25))
                )
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button(isAnswerShown ? "Visa fråga" : "Visa svar") {
                        isAnswerShown.toggle()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Nästa") {
                        goToNext()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
        }
        .navigationTitle("Öva")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadCards() }
        .overlay {
            if showDoneOverlay {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    VStack(spacing: 8) {
                        Text("Klar")
                            .font(.title2).bold()
                            .foregroundStyle(.primary)
                        Text("Tryck för att stänga")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.25))
                    )
                    .onTapGesture { showDoneOverlay = false }
                }
            }
        }
    }

    private func loadCards() {
        let loaded = store.load(for: folder.id)
        cards = loaded
        currentIndex = 0
        isAnswerShown = false
    }

    private func goToNext() {
        guard !cards.isEmpty else { return }
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            isAnswerShown = false
        } else {
            showDoneOverlay = true
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardsPracticeSimpleView(folder: Folder(title: "Exempel", description: "Övning"))
    }
}
