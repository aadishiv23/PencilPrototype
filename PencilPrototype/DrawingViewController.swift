//
//  DrawingViewController.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class DrawingViewController: UIViewController {
    var document: Document?
    private let drawingCanvas = DrawingCanvas()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if let document = document {
            document.open { success in
                if success, let data = document.drawingData {
                    self.drawingCanvas.load(from: data)
                }
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Add Drawing Canvas
        drawingCanvas.frame = view.bounds
        drawingCanvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(drawingCanvas)

        // Add Toolbar
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        let undoButton = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undoStroke))
        let redoButton = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redoStroke))
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearCanvas))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDocument))

        toolbar.setItems([undoButton, redoButton, clearButton, saveButton], animated: false)

        // Constraints
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func undoStroke() {
        drawingCanvas.undoLastStroke()
    }

    @objc private func redoStroke() {
        // Implement redo functionality here
    }

    @objc private func clearCanvas() {
        drawingCanvas.clearCanvas()
    }

    @objc private func saveDocument() {
        guard let document = document else { return }
        document.drawingData = drawingCanvas.save()
        document.save(to: document.fileURL, for: .forOverwriting) { success in
            if success {
                print("Document saved!")
            }
        }
    }
}
