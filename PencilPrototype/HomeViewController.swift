//
//  HomeViewController.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private let collectionView: UICollectionView
    private let createButton = UIButton(type: .system)

    private var documentURLs: [URL] = [] // List of saved documents

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Setup Collection View Layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 150)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Documents"

        // Setup Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DocumentCell.self, forCellWithReuseIdentifier: "DocumentCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        // Setup Create New Document Button
        createButton.setTitle("Create New Document", for: .normal)
        createButton.addTarget(self, action: #selector(createNewDocument), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)

        // Layout
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -20),

            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Load documents
        loadDocuments()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            collectionView.addGestureRecognizer(longPressGesture)
    }

    private func loadDocuments() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            // Filter for files with the `.drawing` extension
            documentURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
                .filter { $0.pathExtension == "drawing" }
            collectionView.reloadData()
        } catch {
            print("Failed to load documents: \(error.localizedDescription)")
        }
    }


    @objc private func createNewDocument() {
        let alertController = UIAlertController(title: "New Document", message: "Enter a name for your document:", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Document Name"
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let name = alertController.textFields?.first?.text, !name.isEmpty else {
                print("Document name is required.")
                return
            }

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let newDocumentURL = documentsDirectory.appendingPathComponent("\(name).drawing")

            let document = Document(fileURL: newDocumentURL)
            document.save(to: newDocumentURL, for: .forCreating) { success in
                if success {
                    self.documentURLs.append(newDocumentURL)
                    self.collectionView.reloadData()
                    self.openDocument(at: newDocumentURL)
                } else {
                    print("Failed to create new document.")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }



    private func openDocument(at url: URL) {
        let document = Document(fileURL: url)
        let drawingVC = ViewController()
        drawingVC.document = document
        navigationController?.pushViewController(drawingVC, animated: true)
    }

    // MARK: - Collection View Data Source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentCell", for: indexPath) as! DocumentCell
        let documentURL = documentURLs[indexPath.item]
        cell.configure(with: documentURL)
        return cell
    }

    // MARK: - Collection View Delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let documentURL = documentURLs[indexPath.item]
        openDocument(at: documentURL)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location), gesture.state == .began else { return }

        let documentURL = documentURLs[indexPath.item]
        let alertController = UIAlertController(title: "Rename Document", message: "Enter a new name:", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.text = documentURL.deletingPathExtension().lastPathComponent
        }

        let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
            guard let newName = alertController.textFields?.first?.text, !newName.isEmpty else {
                print("Document name is required.")
                return
            }

            let newDocumentURL = documentURL.deletingLastPathComponent().appendingPathComponent("\(newName).drawing")

            do {
                try FileManager.default.moveItem(at: documentURL, to: newDocumentURL)
                self.documentURLs[indexPath.item] = newDocumentURL
                self.collectionView.reloadData()
            } catch {
                print("Failed to rename document: \(error.localizedDescription)")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(renameAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
