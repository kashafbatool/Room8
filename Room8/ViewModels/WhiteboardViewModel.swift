import Foundation
import PencilKit

// MARK: - Whiteboard View Model
@MainActor
class WhiteboardViewModel: ObservableObject {
    @Published var notes: [WhiteboardNote] = []
    @Published var drawingData: Data = Data()

    private let storageService = StorageService.shared

    init() {
        load()
    }

    var drawing: PKDrawing {
        get {
            (try? PKDrawing(data: drawingData)) ?? PKDrawing()
        }
        set {
            drawingData = newValue.dataRepresentation()
        }
    }

    func updateDrawing(_ newDrawing: PKDrawing) {
        drawingData = newDrawing.dataRepresentation()
        saveDrawing()
    }

    func clearDrawing() {
        drawingData = PKDrawing().dataRepresentation()
        saveDrawing()
    }

    func addNote(text: String, author: String?) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let trimmedAuthor = (author ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let finalAuthor = trimmedAuthor.isEmpty ? "Roommate" : trimmedAuthor

        let note = WhiteboardNote(text: trimmedText, author: finalAuthor)
        notes.insert(note, at: 0)
        saveNotes()
    }

    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }

    private func load() {
        notes = storageService.loadWhiteboardNotes()
        drawingData = storageService.loadWhiteboardDrawingData()
    }

    private func saveNotes() {
        storageService.saveWhiteboardNotes(notes)
    }

    private func saveDrawing() {
        storageService.saveWhiteboardDrawingData(drawingData)
    }
}
