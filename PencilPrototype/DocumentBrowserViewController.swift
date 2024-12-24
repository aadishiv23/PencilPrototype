//
//  DocumentBrowserViewController.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
    }

    // Open existing document
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let url = documentURLs.first else { return }
        presentDocument(at: url)
    }

    // Create a new document
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL = FileManager.default.temporaryDirectory.appendingPathComponent("Untitled.drawing")

        let document = Document(fileURL: newDocumentURL)
        document.save(to: newDocumentURL, for: .forCreating) { success in
            importHandler(newDocumentURL, .move)
        }
    }

    func presentDocument(at documentURL: URL) {
        let drawingVC = DrawingViewController()
        drawingVC.document = Document(fileURL: documentURL)
        let navController = UINavigationController(rootViewController: drawingVC)
        present(navController, animated: true, completion: nil)
    }
}
