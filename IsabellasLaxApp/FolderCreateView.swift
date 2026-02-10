//
//  MakeYourOwnList.swift
//  IsabellasLaxApp
//
//  Created by Isabella Heidari on 2026-01-15.
//

import SwiftUI
import Foundation


struct FolderCreateView: View {
    
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
                            NavigationLink(destination: FolderOverviewView(folder: $folders[index])) {
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
    FolderCreateView()
}

