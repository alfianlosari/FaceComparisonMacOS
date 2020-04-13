//
//  RekognitionService.swift
//  FaceRecognition
//
//  Created by Alfian Losari on 12/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import Foundation
import PromiseKit

enum APIError: Error {
    case invalidURL
    case invalidSerialization
    case badHTTPResponse
    case error(NSError)
    case noData
}


class RekognitionService {
    
    static let shared = RekognitionService()
    private init() {}
    private let session = URLSession.shared
    
    private let jsonDecoder = JSONDecoder()
    
    // AWS API URL
    // Backend GitHub Repository: https://github.com/alfianlosari/FaceComparisonServerlessAPI

    let baseURL = URL(string: "https://REPLACEURL.com")!
    
    func uploadFileToS3(with data: Data, s3Response: S3preSignedURLResponse) -> Promise<String> {
        return Promise { resolve in
            guard let url = URL(string: s3Response.uploadUrl) else {
                resolve.reject(APIError.invalidURL)
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = data
            session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    resolve.reject(APIError.error(error as NSError))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                    resolve.reject(APIError.badHTTPResponse)
                    return
                }
                resolve.fulfill(s3Response.name)
            }.resume()
        }
    }
    
    
    func getS3preSignedUploadURL() -> Promise<S3preSignedURLResponse> {
        return Promise { resolve in
            let url = baseURL.appendingPathComponent("attachment")
            
            executeDataTaskAndDecode(with: url, method: "POST") { (result: Swift.Result<S3preSignedURLResponse, APIError>) in
                switch result {
                case let .success(response):
                    resolve.fulfill(response)
                case let .failure(error):
                    resolve.reject(error)
                }
            }
        }
    }
    
    func compareFaces(sourceName: String, targetName: String, similarityThreshold: Double = 50) -> Promise<FaceComparisonResponse> {
        let jsonBody: [String: Any] = [
            "sourceImageS3Name": sourceName,
            "targetImageS3Name": targetName,
            "simillarityThreshold": similarityThreshold,
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: jsonBody, options: [])
        let url = baseURL.appendingPathComponent("compare")

        return Promise { resolve in
            executeDataTaskAndDecode(with: url, method: "POST", body: data) { (result: Swift.Result<FaceComparisonResponse, APIError>) in
                switch result {
                case let .success(response):
                    resolve.fulfill(response)
                case let .failure(error):
                    resolve.reject(error)
                }
            }
        }
    }
    
    private func executeDataTaskAndDecode<D: Decodable>(with url: URL, method: String = "GET", body: Data? = nil, completion: @escaping (Swift.Result<D, APIError>) -> ()) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        if let body = body, method != "GET" {
            urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        }
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(.error(error as NSError)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                completion(.failure(.badHTTPResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
            do {
                let model = try self.jsonDecoder.decode(D.self, from: data)
                completion(.success(model))
            } catch let error as NSError{
                print(error.localizedDescription)
                completion(.failure(.invalidSerialization))
            }
        }.resume()
    }
    
}

