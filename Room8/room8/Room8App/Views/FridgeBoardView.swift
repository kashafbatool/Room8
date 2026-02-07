import SwiftUI

struct FridgeBoardView: View {
    @StateObject private var viewModel = WhiteboardViewModel()
    @State private var showingAddNote = false
    @State private var noteText = ""
    @State private var noteAuthor = ""
    @State private var selectedColor: StickyColor = .yellow

    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.notes.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Your fridge is empty!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add your first sticky note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.notes) { note in
                            StickyNoteView(note: note) {
                                viewModel.deleteNote(note)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Fridge Board")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddStickyNoteView(viewModel: viewModel, isPresented: $showingAddNote)
            }
        }
    }
}

// MARK: - Sticky Note Card
struct StickyNoteView: View {
    let note: WhiteboardNote
    let onDelete: () -> Void
    @State private var showingDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                Button {
                    showingDelete = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.title3)
                }
            }

            Text(note.text)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.leading)

            Spacer()

            HStack {
                Text(note.author)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.5))
                Spacer()
                Text(note.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.4))
            }
        }
        .padding()
        .frame(minHeight: 150)
        .background(stickyColor(for: note))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .rotationEffect(.degrees(Double.random(in: -2...2)))
        .confirmationDialog("Delete this note?", isPresented: $showingDelete) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }

    private func stickyColor(for note: WhiteboardNote) -> Color {
        let colors: [Color] = [
            Color(red: 1.0, green: 0.98, blue: 0.6),   // Yellow
            Color(red: 1.0, green: 0.8, blue: 0.9),    // Pink
            Color(red: 0.7, green: 0.9, blue: 1.0),    // Blue
            Color(red: 0.8, green: 1.0, blue: 0.8),    // Green
            Color(red: 1.0, green: 0.9, blue: 0.7),    // Peach
        ]
        return colors[abs(note.id.hashValue) % colors.count]
    }
}

// MARK: - Add Sticky Note Sheet
struct AddStickyNoteView: View {
    @ObservedObject var viewModel: WhiteboardViewModel
    @Binding var isPresented: Bool
    @State private var noteText = ""
    @State private var noteAuthor = ""
    @State private var selectedColor: StickyColor = .yellow

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Write your note")) {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 100)
                }

                Section(header: Text("From (optional)")) {
                    TextField("Your name", text: $noteAuthor)
                }

                Section(header: Text("Color")) {
                    HStack(spacing: 16) {
                        ForEach(StickyColor.allCases, id: \.self) { color in
                            Circle()
                                .fill(color.swiftUIColor)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Add Sticky Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let author = noteAuthor.isEmpty ? "Anonymous" : noteAuthor
                        viewModel.addNote(text: noteText, author: author)
                        isPresented = false
                    }
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Sticky Colors
enum StickyColor: CaseIterable {
    case yellow, pink, blue, green, peach

    var swiftUIColor: Color {
        switch self {
        case .yellow: return Color(red: 1.0, green: 0.98, blue: 0.6)
        case .pink: return Color(red: 1.0, green: 0.8, blue: 0.9)
        case .blue: return Color(red: 0.7, green: 0.9, blue: 1.0)
        case .green: return Color(red: 0.8, green: 1.0, blue: 0.8)
        case .peach: return Color(red: 1.0, green: 0.9, blue: 0.7)
        }
    }
}

#Preview {
    FridgeBoardView()
}
