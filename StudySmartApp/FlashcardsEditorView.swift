import SwiftUI
import Foundation

struct FlashcardsEditorView: View {
    var folder: Folder
    private let store = FlashcardStore()
    
    @Environment(\.editMode) private var editMode
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    @State private var showDeleteAllConfirm = false

    @State private var cards: [Flashcard] = []
    @State private var goToSaved = false

    @State private var newQuestion: String = ""
    @State private var newAnswer: String = ""
    
    @State private var showTrashMenu = false
    @State private var showConfirmDeleteAll = false
    @State private var showDeleteOneSheet = false
    @State private var indexToDelete: Int? = nil
    
    @State private var isSelecting = false
    @State private var selectedIndices: Set<Int> = []
    
    @FocusState private var focusedField: FieldFocus?

    private enum FieldKind: Hashable { case question, answer }
    private struct FieldFocus: Hashable { let index: Int; let kind: FieldKind }

    var body: some View {
        VStack(spacing: 0) {
            // Add new card section
            VStack(alignment: .leading, spacing: 8) {
                Text("Här kan du skapa glosor").font(.headline)
                HStack(spacing: 12) {
                    TextField("Fråga...", text: $newQuestion)
                        .textFieldStyle(.roundedBorder)
                    TextField("Svar...", text: $newAnswer)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        addNewCard()
                    } label: {
                        Text("Spara")
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                    .disabled(newQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding([.horizontal, .top])

            Divider().padding(.vertical, 8)
            
            ScrollView {
                if editMode?.wrappedValue.isEditing == true {
                    if isSelecting {
                        HStack(spacing: 12) {
                            Button("Markera alla") {
                                selectedIndices = Set(cards.indices)
                            }
                            Button("Avmarkera alla") {
                                selectedIndices.removeAll()
                            }
                            Spacer()
                            Button(role: .destructive) {
                                deleteSelected()
                            } label: {
                                Text("Radera (\(selectedIndices.count))")
                            }
                            .disabled(selectedIndices.isEmpty)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(cards.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                if isSelecting {
                                    Button {
                                        if selectedIndices.contains(index) {
                                            selectedIndices.remove(index)
                                        } else {
                                            selectedIndices.insert(index)
                                        }
                                    } label: {
                                        Image(systemName: selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedIndices.contains(index) ? .accentColor : .secondary)
                                    }
                                }
                                TextField("Fråga...", text: $cards[index].question)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: FieldFocus(index: index, kind: .question))
                                    .contentShape(Rectangle())
                                    .onTapGesture { focusedField = FieldFocus(index: index, kind: .question) }
                                TextField("Svar...", text: $cards[index].answer)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: FieldFocus(index: index, kind: .answer))
                                    .contentShape(Rectangle())
                                    .onTapGesture { focusedField = FieldFocus(index: index, kind: .answer) }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding(.top, 4)
                } else {
                    if cards.isEmpty {
                        ContentUnavailableView("Tomt", systemImage: "tray")
                            .padding(.top, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sparade").font(.headline).padding(.horizontal)
                            VStack(spacing: 8) {
                                ForEach(Array(cards.enumerated()), id: \.0) { index, card in
                                    HStack(alignment: .center, spacing: 8) {
                                        if isSelecting {
                                            Button {
                                                if selectedIndices.contains(index) {
                                                    selectedIndices.remove(index)
                                                } else {
                                                    selectedIndices.insert(index)
                                                }
                                            } label: {
                                                Image(systemName: selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(selectedIndices.contains(index) ? .accentColor : .secondary)
                                            }
                                        }
                                        HStack(spacing: 8) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(card.question)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(2)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(Color.gray.opacity(0.08))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(Color.gray.opacity(0.25))
                                            )

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(card.answer)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(2)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 10)
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
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
            }

            Divider()
            HStack {
                Spacer()

                // Höger: Redigera/Klar
                Button {
                    if editMode?.wrappedValue.isEditing == true {
                        editMode?.wrappedValue = .inactive
                        isSelecting = false
                        selectedIndices.removeAll()
                        focusedField = nil
                    } else {
                        editMode?.wrappedValue = .active
                        isSelecting = true
                        selectedIndices.removeAll()
                    }
                } label: {
                    Text(editMode?.wrappedValue.isEditing == true ? "Klar" : "Redigera")
                }
                .buttonStyle(.bordered)
                if isSelecting {
                    Spacer().frame(width: 8)
                    Button("Markera alla") {
                        selectedIndices = Set(cards.indices)
                    }
                    .buttonStyle(.bordered)
                    Button(role: .destructive) {
                        deleteSelected()
                    } label: {
                        Text("Radera (\(selectedIndices.count))")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedIndices.isEmpty)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
        }
        .onAppear { loadCards() }
    }

    private func deleteSelected() {
        guard !selectedIndices.isEmpty else { return }
        let toDelete = selectedIndices
        var remaining: [Flashcard] = []
        for (idx, card) in cards.enumerated() {
            if !toDelete.contains(idx) {
                remaining.append(card)
            }
        }
        cards = remaining
        selectedIndices.removeAll()
        isSelecting = false
        store.save(cards.filter { !$0.question.isEmpty && !$0.answer.isEmpty }, for: folder.id)
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
    }
}

#Preview {
    @State var sampleFolder = Folder(title: "Exempel", description: "Förhandsvisning")
    return NavigationStack {
        FlashcardsEditorView(folder: sampleFolder)
    }
}

