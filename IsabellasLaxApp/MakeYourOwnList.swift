//
//  MakeYourOwnList.swift
//  IsabellasLaxApp
//
//  Created by Isabella Heidari on 2026-01-15.
//

import SwiftUI

struct Folder: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date?

    init(id: UUID = UUID(), title: String, description: String, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
    }
}

struct MakeYourOwnList: View {
    
    @State private var title = ""
    @State private var description = ""
    
    @State private var showField = false
    @State private var folders: [Folder] = []
    private let foldersKey = "savedFolders"
    
    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 8)]
    private let palette: [Color] = [.blue, .green, .yellow, .orange, .red, .purple]
    
    // Spara mapparna till UserDefaults
    private func saveFolders() {
        do {
            let data = try JSONEncoder().encode(folders)
            UserDefaults.standard.set(data, forKey: foldersKey)
        } catch {
            print("Kunde inte spara folders: \(error)")
        }
    }
    
    // Läs in mapparna från UserDefaults
    private func loadFolders() {
        guard let data = UserDefaults.standard.data(forKey: foldersKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Folder].self, from: data)
            folders = decoded
        } catch {
            print("Kunde inte läsa folders: \(error)")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("StudySmart")
                    .font(.largeTitle)
                    .padding(.top)
                
                Button {
                    showField.toggle()
                } label: {
                    HStack (spacing: 8) {
                        Label("+", systemImage: "pencil.and.list.clipboard")
                    }
                    .font(.largeTitle)
                }
                
                Spacer(minLength: 16)
                
                if showField {
                    TextField("Ämne..", text: $title)
                    TextField("Beskrivning..", text: $description)
                    
                    Button("Done") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }
                        
                        let newFolder = Folder(title: trimmedTitle, description: trimmedDescription)
                        folders.append(newFolder)
                        
                        title = ""
                        description = ""
                        showField = false
                    }
                }
                VStack {
                    Spacer()
                    // Grid med klickbara boxar
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(folders.indices, id: \.self) { index in
                            let folder = folders[index]
                            let color = palette[index % palette.count]
                            NavigationLink(destination: ChoosedPageView(folder: $folders[index])) {
                                VStack(alignment: .leading, spacing: 6) {
                                    if let due = folder.dueDate {
                                        Text(due.formatted(date: .abbreviated, time: .omitted))
                                            .font(.headline)
                                            .bold()
                                            .foregroundStyle(.primary)
                                    }
                                    Image(systemName: "pencil.and.list.clipboard")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(color)
                                        .frame(height: 44)
                                        .symbolRenderingMode(.monochrome)
                                        .padding(.bottom, 2)
                                    Text(folder.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if !folder.description.isEmpty {
                                        Text(folder.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(height: 140)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(color.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(color, lineWidth: 4)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    Spacer()
                }
               
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear { loadFolders() }
        .onChange(of: folders) { oldValue, newValue in
            saveFolders()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Lightweight local model for the input on sida 2
private struct DraftCard { var question: String; var answer: String }

#Preview {
    MakeYourOwnList()
}

// Enkel vy för att spara glosor per mapp
struct FlashcardsEditorView: View {
    var folder: Folder
    // Starta med två tomma rader
    @State private var pairs: [(question: String, answer: String)] = [("", "")]
    @State private var showSavedBanner = false
    @State private var showSavedList = false
    @State private var savedPreview: [(String, String)] = []
    @State private var goToSaved = false

    private var storageKey: String { "flashcards_" + folder.id.uuidString }

    var body: some View {
        VStack(spacing: 0) {
            // Rubriker för kolumner
            HStack {
                Text("Fråga").font(.headline)
                Spacer()
                Text("Svar").font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            List {
                ForEach(pairs.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        TextField("Fråga...", text: $pairs[index].question)
                            .textFieldStyle(.roundedBorder)
                        TextField("Svar...", text: $pairs[index].answer)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    pairs.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button {
                    pairs.append(("", ""))
                } label: {
                    Label("Lägg till rad", systemImage: "plus.circle")
                }

                Spacer()

                Button {
                    savePairs()
                    refreshSavedPreview()
                } label: {
                    Label("Spara", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            if !savedPreview.isEmpty {
                Button {
                    goToSaved = true
                } label: {
                    Label("Sparade ord", systemImage: "bookmark")
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Spara glosor")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToSaved) {
            SavedFlashcardsView(folder: folder)
        }
        .onAppear { loadPairs(); refreshSavedPreview() }
    }

    // MARK: - Lagring i UserDefaults (enkel första version)
    private func savePairs() {
        let cleaned = pairs
            .map { ($0.question.trimmingCharacters(in: .whitespacesAndNewlines),
                     $0.answer.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.0.isEmpty || !$0.1.isEmpty }
        let dictArray = cleaned.map { ["q": $0.0, "a": $0.1] }
        UserDefaults.standard.set(dictArray, forKey: storageKey)
    }

    private func loadPairs() {
        guard let saved = UserDefaults.standard.array(forKey: storageKey) as? [[String: String]] else { return }
        let loaded: [(String, String)] = saved.compactMap { dict in
            if let q = dict["q"], let a = dict["a"] { return (q, a) }
            return nil
        }
        if !loaded.isEmpty {
            self.pairs = loaded
        }
    }
    
    private func refreshSavedPreview() {
        guard let saved = UserDefaults.standard.array(forKey: storageKey) as? [[String: String]] else {
            savedPreview = []
            return
        }
        savedPreview = saved.compactMap { dict in
            if let q = dict["q"], let a = dict["a"] { return (q, a) }
            return nil
        }
    }
}

struct SavedFlashcardsView: View {
    var folder: Folder
    private var storageKey: String { "flashcards_" + folder.id.uuidString }
    @State private var savedPairs: [(String, String)] = []
    var body: some View {
        List {
            if savedPairs.isEmpty {
                ContentUnavailableView("Inget sparat ännu", systemImage: "tray")
            } else {
                Section {
                    HStack {
                        Text("Fråga").font(.headline)
                        Spacer()
                        Text("Svar").font(.headline)
                    }
                    .padding(.vertical, 4)
                }

                ForEach(savedPairs.indices, id: \.self) { idx in
                    let pair = savedPairs[idx]
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(pair.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(pair.1)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Sparat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadSaved() }
    }

    private func loadSaved() {
        guard let saved = UserDefaults.standard.array(forKey: storageKey) as? [[String: String]] else {
            savedPairs = []
            return
        }
        let loaded: [(String, String)] = saved.compactMap { dict in
            if let q = dict["q"], let a = dict["a"] { return (q, a) }
            return nil
        }
        savedPairs = loaded
    }
}

