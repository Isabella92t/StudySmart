//
//  MakeYourOwnList.swift
//  IsabellasLaxApp
//
//  Created by Isabella Heidari on 2026-01-15.
//

import SwiftUI

// Modell för en mapp (titel + beskrivning)
struct Folder: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

// Detaljvy som visar titel och beskrivning och låter dig lägga till ord
struct FolderDetailView: View {
    var folder: Folder

    @State private var term = ""
    @State private var meaning = ""
    @State private var items: [(term: String, meaning: String)] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(folder.title)
                .font(.title).bold()

            if !folder.description.isEmpty {
                Text(folder.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text("Lägg till ord")
                .font(.headline)

            TextField("Ord", text: $term)
                .textFieldStyle(.roundedBorder)

            TextField("Förklaring", text: $meaning)
                .textFieldStyle(.roundedBorder)

            Button("Lägg till") {
                let t = term.trimmingCharacters(in: .whitespacesAndNewlines)
                let m = meaning.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty else { return }
                items.append((t, m))
                term = ""
                meaning = ""
            }

            List {
                ForEach(items.indices, id: \.self) { i in
                    VStack(alignment: .leading) {
                        Text(items[i].term).bold()
                        Text(items[i].meaning)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Mapp")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MakeYourOwnList: View {
    @State private var title = ""
    @State private var description = ""

    @State private var showField = false
    @State private var folders: [Folder] = []
    private let foldersKey = "savedFolders"

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
    private let palette: [Color] = [.blue, .green, .yellow, .orange, .red]

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
                    .padding()

                HStack {
                    Text("Add folder")

                    Button("+") {
                        showField.toggle()
                    }
                    .font(.largeTitle)
                }

                if showField {
                    TextField("Skriv här..", text: $title)
                    TextField("Beskrivning", text: $description)

                    Button("Spara") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }

                        let newFolder = Folder(title: trimmedTitle, description: trimmedDescription)
                        folders.append(newFolder)
                        saveFolders()

                        title = ""
                        description = ""
                        showField = false
                    }
                }

                // Grid med klickbara boxar
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(Array(folders.enumerated()), id: \.element) { index, folder in
                        let color = palette[index % palette.count]

                        NavigationLink(value: folder) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(folder.title)
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                if !folder.description.isEmpty {
                                    Text(folder.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(color.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(color, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .onAppear { loadFolders() }
            .navigationDestination(for: Folder.self) { folder in
                FolderDetailView(folder: folder)
            }
        }
    }
}

#Preview {
    MakeYourOwnList()
}
