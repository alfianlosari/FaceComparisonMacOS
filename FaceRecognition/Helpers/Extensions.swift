//
//  Extensions.swift
//  FaceRecognition
//
//  Created by Alfian Losari on 13/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import Cocoa

extension Double {
    
    var percentageText: String {
        return FaceComparisonResponse.numberFormatter.string(from: NSNumber(value: self / 100)) ?? "0.0%"
    }
}

extension NSImage {
    
    var compressedData: Data? {
        guard
            let data = tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: data),
            let imageData = imageRep.representation(using: .jpeg, properties: [.compressionFactor: 0.2])
            else { return nil }
        return imageData
    }
}

