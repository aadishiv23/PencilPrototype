//
//  PenPickerView.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class PenPickerView: UIView {
    var onColorSelected: ((UIColor) -> Void)?
    var onWidthSelected: ((CGFloat) -> Void)?
    var onEraserSelected: (() -> Void)?

    private let colors: [UIColor] = [.black, .red, .blue, .green, .yellow]
    private let widths: [CGFloat] = [1.0, 3.0, 5.0, 10.0, 20.0]
    private var selectedColor: UIColor = .black
    private var selectedWidth: CGFloat = 5.0
    private var isEraserActive: Bool = false

    private let colorButtons: [UIButton] = []
    private let widthButtons: [UIButton] = []
    private let eraserButton = UIButton(type: .system)
    private let colorIndicator = UIView()
    private let sizeIndicator = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Add color buttons
        for color in colors {
            let button = UIButton()
            button.backgroundColor = color
            button.layer.cornerRadius = 15
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.clear.cgColor
            button.frame.size = CGSize(width: 30, height: 30)
            button.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        // Add width buttons
        let widthStack = UIStackView()
        widthStack.axis = .horizontal
        widthStack.spacing = 10
        for width in widths {
            let button = UIButton(type: .system)
            button.setTitle("\(Int(width))", for: .normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.clear.cgColor
            button.addTarget(self, action: #selector(widthSelected(_:)), for: .touchUpInside)
            widthStack.addArrangedSubview(button)
        }

        // Add eraser button
        eraserButton.setTitle("Eraser", for: .normal)
        eraserButton.setTitleColor(.white, for: .normal)
        eraserButton.backgroundColor = .systemGray
        eraserButton.layer.cornerRadius = 10
        eraserButton.addTarget(self, action: #selector(eraserSelected), for: .touchUpInside)
        stackView.addArrangedSubview(eraserButton)

        // Add indicators
        colorIndicator.backgroundColor = selectedColor
        colorIndicator.layer.cornerRadius = 10
        colorIndicator.layer.borderWidth = 2
        colorIndicator.layer.borderColor = UIColor.black.cgColor
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false

        sizeIndicator.text = "\(Int(selectedWidth))"
        sizeIndicator.textColor = .black
        sizeIndicator.font = .boldSystemFont(ofSize: 16)
        sizeIndicator.textAlignment = .center
        sizeIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Layout
        let indicatorsStack = UIStackView(arrangedSubviews: [colorIndicator, sizeIndicator])
        indicatorsStack.axis = .horizontal
        indicatorsStack.spacing = 10
        indicatorsStack.alignment = .center
        indicatorsStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [stackView, widthStack, indicatorsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 15
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            colorIndicator.widthAnchor.constraint(equalToConstant: 30),
            colorIndicator.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func colorSelected(_ sender: UIButton) {
        guard let color = sender.backgroundColor else { return }
        selectedColor = color
        isEraserActive = false
        eraserButton.backgroundColor = .systemGray
        updateIndicators()
        onColorSelected?(color)
    }

    @objc private func widthSelected(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
              let widthValue = Double(title) else { return } // Convert String to Double
        let width = CGFloat(widthValue) // Convert Double to CGFloat
        selectedWidth = width
        updateIndicators()
        onWidthSelected?(width)
    }


    @objc private func eraserSelected() {
        isEraserActive = true
        eraserButton.backgroundColor = .systemBlue
        updateIndicators()
        onEraserSelected?()
    }

    private func updateIndicators() {
        colorIndicator.backgroundColor = isEraserActive ? .white : selectedColor
        sizeIndicator.text = isEraserActive ? "Eraser" : "\(Int(selectedWidth))"
    }
}
