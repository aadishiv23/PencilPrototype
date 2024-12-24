//
//  Document.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class Document: UIDocument {
    var drawingData: Data? // Stores serialized drawing paths

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            drawingData = data
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        return drawingData ?? Data()
    }
}
