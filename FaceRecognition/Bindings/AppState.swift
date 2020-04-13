//
//  AppState.swift
//  FaceRecognition
//
//  Created by Alfian Losari on 12/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import Combine
import Cocoa
import PromiseKit

class AppState: NSObject, ObservableObject {
    
    static let shared = AppState()
    private override init() {}
    let service = RekognitionService.shared
    
    @Published var state: FaceRecognitionPipelineState = .initial
    @Published var similarity: Double = 75
    @Published var sourceImage: NSImage?
    @Published var targetImage: NSImage?
    
    func handleAnalyzeClicked() {
        guard
            let sourceImgData = sourceImage?.compressedData,
            let targetImgData = targetImage?.compressedData
            else { return }
        
        firstly { () -> Promise<(S3preSignedURLResponse, S3preSignedURLResponse)> in
            self.state = .gettingPreSignedUploadURL
            return when(fulfilled:
                self.service.getS3preSignedUploadURL(),
                self.service.getS3preSignedUploadURL()
            )
        }.then { (sourceS3: S3preSignedURLResponse, targetS3: S3preSignedURLResponse) -> Promise<(String, String)> in
            self.state = .uploadingToS3
            return when(fulfilled:
                self.service.uploadFileToS3(with: sourceImgData, s3Response: sourceS3),
                 self.service.uploadFileToS3(with: targetImgData, s3Response: targetS3)
            )
        }.then { (sourceName: String, targetName: String) -> Promise<FaceComparisonResponse> in
            self.state = .analyzingImages
            return self.service.compareFaces(sourceName: sourceName, targetName: targetName, similarityThreshold: self.similarity)
        }.done { (resp: FaceComparisonResponse) in
            self.state = .completed(resp.resultText)
        }.catch { (error) in
            self.state = .error(error)
        }
    }
    
    func handleRetryClicked() {
        handleAnalyzeClicked()
    }
    
    func handleClearClicked() {
        self.sourceImage = nil
        self.targetImage = nil
        self.state = .initial
    }
}
