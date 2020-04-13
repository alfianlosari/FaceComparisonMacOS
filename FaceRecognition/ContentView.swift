//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Alfian Losari on 12/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import SwiftUI
import PromiseKit

struct ContentView: View {
    
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                ImageFileSelectView(title: "Source Face", isButtonShown: appState.state == .initial, image: self.$appState.sourceImage)
                ImageFileSelectView(title: "Target Face", isButtonShown: appState.state == .initial, image: self.$appState.targetImage)
            }
            
            Text(appState.state.description)
                .font(.headline)
            
            thresholdSlider
            stateActionView
        }
        .padding(.vertical)
        .padding(.horizontal)
        .frame(minWidth: 768, idealWidth: 768, maxWidth: 1024, minHeight: 648, maxHeight: 648)
    }
    
    var thresholdSlider: some View {
        switch appState.state {
        case .initial, .completed:
            return AnyView(Slider(value: self.$appState.similarity, in: 60...95, minimumValueLabel: Text("60%"), maximumValueLabel: Text("95%")) {
                Text("Similarity Threshold")
            }
            .frame(width: 300))
            
        default:
            return AnyView(EmptyView())
        }
    }
    
    var stateActionView: some View {
        switch self.appState.state {
        case .initial where self.appState.sourceImage != nil && self.appState.targetImage != nil:
            return AnyView(Button(action: self.appState.handleAnalyzeClicked) {
                Text("Compare Faces")
            })
            
        case .uploadingToS3, .analyzingImages, .gettingPreSignedUploadURL:
            return AnyView(ProgressView())
            
        case .error(_), .completed(_):
            return AnyView(VStack {
                Button(action: self.appState.handleRetryClicked) {
                    Text("Retry")
                }
                Button(action: self.appState.handleClearClicked) {
                    Text("Reset")
                }
            })
            
            
        default:
            return AnyView(EmptyView())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
