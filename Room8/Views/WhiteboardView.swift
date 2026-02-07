import SwiftUI
import PencilKit
import UIKit

// MARK: - Whiteboard View
struct WhiteboardView: View {
    @StateObject private var viewModel = WhiteboardViewModel()
    @State private var noteText = ""
    @State private var noteAuthor = ""
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Whiteboard")) {
                    WhiteboardCanvasView(
                        drawing: Binding(
                            get: { viewModel.drawing },
                            set: { viewModel.updateDrawing($0) }
                        )
                    )
                    .frame(height: 320)
                    .listRowInsets(EdgeInsets())

                    HStack {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("Clear Canvas", systemImage: "trash")
                        }
                        Spacer()
                        Text("Auto-saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Add Note")) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Write a note or a birthday message...", text: $noteText, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        TextField("From (optional)", text: $noteAuthor)

                        HStack {
                            Spacer()
                            Button("Post") {
                                viewModel.addNote(text: noteText, author: noteAuthor)
                                noteText = ""
                                noteAuthor = ""
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Notes")) {
                    if viewModel.notes.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)
                                Text("No notes yet")
                                    .font(.headline)
                                Text("Add a note to get started")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    } else {
                        ForEach(viewModel.notes) { note in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(note.text)
                                    .font(.body)
                                HStack {
                                    Text(note.author)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(note.createdAt, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: viewModel.deleteNotes)
                    }
                }
            }
            .navigationTitle("Whiteboard")
            .confirmationDialog(
                "Clear the canvas?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) {
                    viewModel.clearDrawing()
                }
            }
        }
    }
}

// MARK: - PencilKit Canvas Wrapper
struct WhiteboardCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = UIColor.systemBackground

        if let window = keyWindow() {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.setVisible(true, forFirstResponder: canvasView)
            toolPicker?.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

#Preview {
    WhiteboardView()
}
