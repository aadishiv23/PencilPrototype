//
//  ViewController.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class ViewController: UIViewController {

    var document: Document? // The UIDocument representing the current file
    private let drawingCanvas = DrawingCanvas()
    private let penPickerView = PenPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Setup drawing canvas
        drawingCanvas.frame = view.bounds
        drawingCanvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(drawingCanvas)

        // Setup pen picker
        penPickerView.frame = CGRect(x: 20, y: view.bounds.height - 150, width: view.bounds.width - 40, height: 100)
        penPickerView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        penPickerView.onColorSelected = { [weak self] color in
            self?.drawingCanvas.strokeColor = color
        }
        penPickerView.onWidthSelected = { [weak self] width in
            self?.drawingCanvas.strokeWidth = width
        }
        penPickerView.onEraserSelected = { [weak self] in
            self?.drawingCanvas.strokeColor = .white
        }
        view.addSubview(penPickerView)

        // Add toolbar with Save and Close
        setupToolbar()

        // Load document data
        if let document = document {
            document.open { success in
                if success, let data = document.drawingData {
                    self.drawingCanvas.load(from: data)
                }
            }
        }
        
        if #available(iOS 12.1, *) {
               view.isExclusiveTouch = true // Prevents simultaneous touches
               self.view.addInteraction(UIPencilInteraction()) // Pencil-specific interaction
           }
    }

    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearCanvas))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDocument))
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeDocument))

        toolbar.setItems([clearButton, saveButton, closeButton], animated: false)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func clearCanvas() {
        drawingCanvas.clearCanvas()
    }

    @objc private func saveDocument() {
        guard let document = document else { return }
        document.drawingData = drawingCanvas.save() // Get the serialized data from the canvas

        document.save(to: document.fileURL, for: .forOverwriting) { success in
            if success {
                print("Document saved successfully!")
            } else {
                print("Failed to save document.")
            }
        }
    }


    @objc private func closeDocument() {
        document?.close(completionHandler: { success in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to close document.")
            }
        })
    }
}
