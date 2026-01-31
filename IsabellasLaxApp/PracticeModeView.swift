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
                .fill(.ultraThickMaterial)
                .shadow(radius: 4)

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

struct PracticeModeView: View {
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

    var body: some View {
        VStack(spacing: 16) {
            Text(folder.title)
                .font(.title2)
                .bold()
                .padding(.top)

            if finished {
                EmptyView()
            } else if shuffledCards.isEmpty {
                ContentUnavailableView(
                    "Inga flashcards",
                    systemImage: "rectangle.stack.badge.plus",
                    description: Text("Lägg till flashcards för att börja öva.")
                )
                .padding()
            } else {
                VStack(spacing: 20) {
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
                }
                .padding()
            }
        }
        .navigationTitle("Övningsläge")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            cards = store.load(for: folder.id)
            shuffledCards = cards.shuffled()
        }
    }

    private func mark(correct: Bool) {
        if correct { correctCount += 1 } else { incorrectCount += 1 }
        advance()
    }

    private func advance() {
        showingAnswer = false
        if currentIndex + 1 < shuffledCards.count {
            currentIndex += 1
        } else {
            restart()
        }
    }

    private func restart() {
        currentIndex = 0
        showingAnswer = false
        finished = false
        correctCount = 0
        incorrectCount = 0
        shuffledCards = cards.shuffled()
        currentIndex = 0
    }
}

struct PracticeModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PracticeModeView(folder: Folder(title: "Biologi", description: "Kapitel 3"))
        }
    }
}
