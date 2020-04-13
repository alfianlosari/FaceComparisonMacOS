//
//  ImageFileSelect.swift
//  FaceRecognition
//
//  Created by Alfian Losari on 12/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import SwiftUI

struct ImageFileSelectView: View {
    
    let title: String
    let isButtonShown: Bool
    @Binding var image: NSImage?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                if isButtonShown {
                    Button(action: selectFile) {
                        Text("Select image")
                    }
                }
            }
            ImageFileView(image: self.$image, isButtonShown: self.isButtonShown)

        }
    }
    
    private func selectFile() {
        NSOpenPanel.openImage { (result) in
            if case let .success(image) = result {
                self.image = image
            }
        }
    }
}

struct ImageFileView: View {
    
    @Binding var image: NSImage?
    let isButtonShown: Bool

    var body: some View {
        ZStack {
            if image != nil {
                Image(nsImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Drag and drop image file")
                    .frame(width: 320)
            }
        }
        .frame(height: 320)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
            
        .onDrop(of: ["public.file-url"], isTargeted: nil, perform: handleOnDrop(providers:))
    }
        
    private func handleOnDrop(providers: [NSItemProvider]) -> Bool {
        guard isButtonShown else { return false }
        if let item = providers.first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data {
                        let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                        guard let image = NSImage(contentsOf: url) else {
                            return
                        }
                        self.image = image
                    }
                }
            }
            return true
        }
        return false
    }
}
