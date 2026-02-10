import SwiftUI

struct FlippableCard<Front: View, Back: View>: View {
    @Binding var isFlipped: Bool
    let front: Front
    let back: Back

    @State private var rotation: Double = 0

    init(isFlipped: Binding<Bool>, @ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self._isFlipped = isFlipped
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isFlipped ? Color.blue.opacity(0.25) : Color.blue.opacity(0.15))
                .shadow(radius: 4)
                .animation(.easeInOut, value: isFlipped)

            ZStack { front }
                .opacity(rotation < 90 ? 1 : 0)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))

            ZStack { back }
                .opacity(rotation >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(rotation + 180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(0), axis: (x: 0, y: 0, z: 0), perspective: 0.6)
        .onChange(of: isFlipped) { old, new in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                rotation = new ? 180 : 0
            }
        }
        .onAppear {
            rotation = isFlipped ? 180 : 0
        }
        .clipped()
    }
}

struct FlashcardsPracticeAdvancedView: View {
    let folder: Folder

    private let store = FlashcardStore()
    @State private var cards: [Flashcard] = []
    @State private var shuffledCards: [Flashcard] = []

    @State private var currentIndex: Int = 0
    @State private var showingAnswer: Bool = false
    @State private var correctCount: Int = 0
    @State private var incorrectCount: Int = 0
    @State private var finished: Bool = false
    @State private var layAsidePressed: Bool = false

    @State private var laidAside: [Flashcard] = []

    var body: some View {
        VStack(spacing: 16) {
            Text(folder.title)
                .font(.title2)
                .bold()
                .padding(.top)

            if finished {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("Klar!")
                        .font(.title2)
                        .bold()
                    Text("Du har övat färdigt alla kort.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !laidAside.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "tray")
                                Text("Undanlagda kort (") + Text("\(laidAside.count)") + Text(")")
                            }
                            .font(.headline)

                            // A compact list/box of laid-aside items
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(laidAside.prefix(5)) { card in
                                    Text("• \(card.question)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                if laidAside.count > 5 {
                                    Text("… och \(laidAside.count - 5) fler")
                                        .font(.footnote)
                                        .foregroundStyle(.tertiary)
                                }
                            }

                            Button {
                                practiceLaidAside()
                            } label: {
                                Label("Öva undanlagda", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button(role: .destructive) {
                                laidAside = []
                                store.clearLaidAside(for: folder.id)
                            } label: {
                                Label("Rensa undanlagda", systemImage: "trash")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.gray.opacity(0.25)))
                    }

                    Button("Börja om") { restart() }
                        .buttonStyle(.bordered)
                }
                .padding()
            } else if shuffledCards.isEmpty {
                ContentUnavailableView(
                    "Inga flashcards",
                    systemImage: "rectangle.stack.badge.plus",
                    description: Text("Lägg till flashcards för att börja öva.")
                )
                .padding()
            } else {
                VStack(spacing: 20) {
                    if currentIndex < shuffledCards.count {
                        FlippableCard(isFlipped: $showingAnswer) {
                            VStack(spacing: 8) {
                                Text(shuffledCards[currentIndex].question)
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Text("(Fråga)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                        } back: {
                            VStack(spacing: 8) {
                                Text(shuffledCards[currentIndex].answer)
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Text("(Svar)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 320)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                showingAnswer.toggle()
                            }
                        }

                        HStack(spacing: 16) {
                            Button {
                                mark(correct: false)
                            } label: {
                                Label("Lägg undan", systemImage: "xmark.circle")
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .scaleEffect(layAsidePressed ? 0.95 : 1.0)
                            .offset(y: layAsidePressed ? 1 : 0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: layAsidePressed)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if layAsidePressed == false {
                                            layAsidePressed = true
                                        }
                                    }
                                    .onEnded { _ in
                                        layAsidePressed = false
                                    }
                            )

                            Button {
                                mark(correct: true)
                            } label: {
                                Label("Nästa", systemImage: "checkmark.circle")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }

                        Text("\(currentIndex + 1) / \(shuffledCards.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if !laidAside.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "tray")
                                    Text("Undanlagda (") + Text("\(laidAside.count)") + Text(")")
                                }
                                .font(.headline)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(laidAside) { card in
                                            Text(card.question)
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.gray.opacity(0.12)))
                                                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.gray.opacity(0.25)))
                                                .lineLimit(1)
                                        }
                                    }
                                }

                                Button {
                                    practiceLaidAside()
                                } label: {
                                    Label("Öva undanlagda", systemImage: "arrow.triangle.2.circlepath")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.gray.opacity(0.07)))
                        }
                    } else {
                        ContentUnavailableView(
                            "Inga flashcards",
                            systemImage: "rectangle.stack.badge.plus",
                            description: Text("Lägg till flashcards för att börja öva.")
                        )
                        .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Övningsläge")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            cards = store.load(for: folder.id)
            shuffledCards = cards.shuffled()
            laidAside = store.loadLaidAside(for: folder.id)

            if cards.isEmpty {
                shuffledCards = []
                finished = false
                currentIndex = 0
            }

            finished = false
            currentIndex = 0
            showingAnswer = false
        }
    }

    private func mark(correct: Bool) {
        if correct {
            correctCount += 1
        } else {
            incorrectCount += 1
            let card = shuffledCards[currentIndex]
            if laidAside.contains(card) == false {
                laidAside.append(card)
                store.saveLaidAside(laidAside, for: folder.id)
            }
        }
        advance()
    }

    private func advance() {
        showingAnswer = false
        if currentIndex + 1 < shuffledCards.count {
            currentIndex += 1
        } else {
            finished = true
        }
    }

    private func restart() {
        finished = false
        correctCount = 0
        incorrectCount = 0
        showingAnswer = false
        currentIndex = 0
        shuffledCards = cards.shuffled()
    }

    private func practiceLaidAside() {
        guard !laidAside.isEmpty else { return }
        finished = false
        showingAnswer = false
        correctCount = 0
        incorrectCount = 0
        currentIndex = 0
        shuffledCards = laidAside.shuffled()
    }
}

struct FlashcardsPracticeAdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FlashcardsPracticeAdvancedView(folder: Folder(title: "Ämne", description: "Kapitel 1"))
        }
    }
}
