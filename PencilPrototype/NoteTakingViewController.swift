//
//  NoteTakingViewController.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class NoteTakingViewController: UIViewController {
    private let drawingCanvas = DrawingCanvas()
    private let penPickerView = PenPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Setup canvas
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
        view.addSubview(penPickerView)

        // Add clear button
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        clearButton.frame = CGRect(x: view.bounds.width - 80, y: 40, width: 60, height: 30)
        view.addSubview(clearButton)
    }

    @objc private func clearCanvas() {
        drawingCanvas.clearCanvas()
    }
}
