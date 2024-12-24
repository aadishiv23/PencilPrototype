//
//  DocumentCell.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class DocumentCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let previewImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor

        // Setup preview image
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewImageView)

        // Setup name label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            previewImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with url: URL) {
        nameLabel.text = url.deletingPathExtension().lastPathComponent

        // Generate preview
        let document = Document(fileURL: url)
        document.open { success in
            if success, let data = document.drawingData {
                let drawingCanvas = DrawingCanvas()
                drawingCanvas.load(from: data)
                self.previewImageView.image = drawingCanvas.snapshot()
                document.close(completionHandler: nil)
            }
        }
    }
}
