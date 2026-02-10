import SwiftUI

struct FolderOverviewView: View {
    @Binding var folder: Folder
    @State private var showFlashcardOptions = false
    @State private var showFlashcardMenu = false
    @State private var goToCreate = false
    @State private var goToPractice = false
    @State private var showDatePicker = false
    @State private var tempDate = Date()
    @State private var goToGlossary = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(folder.title)
                        .font(.largeTitle)
                        .bold()

                    if !folder.description.isEmpty {
                        Text(folder.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .navigationTitle(folder.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDatePicker = true
                } label: {
                    Label("Datum", systemImage: "calendar")
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                VStack(spacing: 16) {
                    DatePicker("Välj datum", selection: $tempDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                    Spacer()
                }
                .navigationTitle("Välj datum")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Avbryt") { showDatePicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Spara") {
                            folder.dueDate = tempDate
                            showDatePicker = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFlashcardMenu) {
            NavigationStack {
                List {
                    Button {
                        showFlashcardMenu = false
                        goToCreate = true
                    } label: {
                        Label("Skapa flashcards", systemImage: "plus.rectangle.on.rectangle")
                    }

                    Button {
                        showFlashcardMenu = false
                        goToPractice = true
                    } label: {
                        Label("Öva flashcards", systemImage: "bolt.horizontal.circle")
                    }
                }
                .navigationTitle("Flashcards")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Stäng") { showFlashcardMenu = false }
                    }
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            HStack(spacing: 16) {
                Button {
                    goToPractice = true
                } label: {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.blue)
                        .padding(12)
                        .background(
                            Circle().fill(Color.blue.opacity(0.15))
                        )
                        .accessibilityLabel("Flashcards")
                }

                Button {
                    goToCreate = true
                } label: {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.green)
                        .font(.system(size: 24, weight: .bold))
                        .padding(12)
                        .background(
                            Circle().fill(Color.green.opacity(0.15))
                        )
                        .accessibilityLabel("Lägg till flashcards")
                }
                
                Button {
                    goToGlossary = true
                } label: {
                    Image(systemName: "book")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.purple)
                        .padding(12)
                        .background(
                            Circle().fill(Color.purple.opacity(0.15))
                        )
                        .accessibilityLabel("Glosor")
                }
            }
            .padding([.leading, .bottom], 24)
        }
        .navigationDestination(isPresented: $goToCreate) {
            FlashcardsEditorView(folder: folder)
        }
        .navigationDestination(isPresented: $goToPractice) {
            FlashcardsPracticeAdvancedView(folder: folder)
        }
        .navigationDestination(isPresented: $goToGlossary) {
            GlossaryPracticeView()
        }
    }
}

// Note: This file expects `Folder`, `FlashcardsEditorView`, `PracticeModeView`, and `SavedFlashcardsView` to be available in the module.
#Preview {
    @State var sampleFolder = Folder(title: "Ämne", description: "Beskrivning")
    NavigationStack {
        FolderOverviewView(folder: $sampleFolder)
    }
}

