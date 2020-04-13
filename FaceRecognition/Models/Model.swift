//
//  Model.swift
//  FaceRecognition
//
//  Created by Alfian Losari on 13/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import Foundation

struct S3preSignedURLResponse: Decodable {
    let uploadUrl: String
    let name: String
}

struct FaceComparisonResponse: Decodable {
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    enum CodingKeys: String, CodingKey {
        case faceMatches = "FaceMatches"
        case unmatchedFaces = "UnmatchedFaces"
        case sourceImageFace = "SourceImageFace"
    }
    
    var sourceImageFace: SourceImageFace?
    var faceMatches: [FaceMatches]?
    var unmatchedFaces: [FaceMatches]?
    
    
    struct FaceMatches: Decodable {
        enum CodingKeys: String, CodingKey {
            case similarity = "Similarity"
        }
        
        let similarity: Double?
    }
    
    struct SourceImageFace: Decodable {
        enum CodingKeys: String, CodingKey {
            case confidence = "Confidence"
        }
        var confidence: Double?
    }
    
    
    var resultText: String {
        if let faceMatchSimilarity = self.faceMatches?.first?.similarity {
            return "FACE MATCH 😃!. Similarity: \(faceMatchSimilarity.percentageText)"
        } else if let _ = self.unmatchedFaces?.first {
            return "FACE NOT MATCH 😢!"
        } else {
            return "No Results"
        }
    }

}


enum FaceRecognitionPipelineState {
    
    case initial
    case gettingPreSignedUploadURL
    case uploadingToS3
    case analyzingImages
    case error(Error)
    case completed(String)
    
    var description: String {
        switch self {
        case .initial:
            return "Please assign source and target faces to begin"
            
        case .gettingPreSignedUploadURL:
            return "Fetching presigned S3 upload URL"
            
        case .uploadingToS3:
            return "Uploading images to S3 Bucket"
            
        case .analyzingImages:
            return "Analyzing images to find similarity"
            
        case let .error(error as NSError):
            return "Error: \(error.localizedDescription)"
            
        case let .completed(result):
            return result
            
        }
    }
}

extension FaceRecognitionPipelineState: Equatable {
    
    static func == (lhs: FaceRecognitionPipelineState, rhs: FaceRecognitionPipelineState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.uploadingToS3, .uploadingToS3):
            return true
        case (.analyzingImages, .analyzingImages):
            return true
        case (let .error(error), let .error(error2)):
            return error.localizedDescription == error2.localizedDescription
        case (let .completed(result), let .completed(result2)):
            return result == result2
        default:
            return false
        }
    }
}


