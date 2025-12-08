//
//  S3UploadService.swift
//  RuanKao
//
//  Created by fandong on 2025/12/08.
//

import Foundation
import CryptoKit
import UIKit

/// S3-compatible upload service for Cloudflare R2
class S3UploadService {
    static let shared = S3UploadService()
    
    // Cloudflare R2 Configuration
    private let accessKeyId = "a41119fea8804a55ec4f708c06f40d4b"
    private let secretAccessKey = "c18ba17824a288161116bfdcb90e713480c1512846cb9e4f24049229ab43e194"
    private let endpoint = "https://3747930441355add7360314e477aed2b.r2.cloudflarestorage.com"
    private let bucket = "ruankao"
    private let region = "auto"
    private let publicBaseUrl = "https://static.xiaobingkj.icu"
    
    private init() {}
    
    /// Upload image to Cloudflare R2 and return the public URL
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - completion: Callback with Result containing the public URL or error
    func uploadAvatar(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Generate unique filename
        let uuid = UUID().uuidString.lowercased()
        let fileName = "avatars/\(uuid).jpg"
        
        // Compress image to JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(S3UploadError.imageCompressionFailed))
            return
        }
        
        // Perform upload
        performUpload(data: imageData, fileName: fileName, contentType: "image/jpeg") { result in
            switch result {
            case .success:
                let publicUrl = "\(self.publicBaseUrl)/\(fileName)"
                completion(.success(publicUrl))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func performUpload(data: Data, fileName: String, contentType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(endpoint)/\(bucket)/\(fileName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        
        // Set headers
        let date = ISO8601DateFormatter().string(from: Date())
        let amzDate = formatAmzDate(Date())
        let dateStamp = formatDateStamp(Date())
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(amzDate, forHTTPHeaderField: "x-amz-date")
        request.setValue(url.host!, forHTTPHeaderField: "Host")
        request.setValue(sha256Hash(data), forHTTPHeaderField: "x-amz-content-sha256")
        
        // Sign request with AWS Signature V4
        let signedRequest = signRequest(request: request, method: "PUT", path: "/\(bucket)/\(fileName)", payload: data, dateStamp: dateStamp, amzDate: amzDate)
        
        URLSession.shared.dataTask(with: signedRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(S3UploadError.invalidResponse))
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    let responseText = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    completion(.failure(S3UploadError.uploadFailed(statusCode: httpResponse.statusCode, message: responseText)))
                }
            }
        }.resume()
    }
    
    // MARK: - AWS Signature V4 Implementation
    
    private func signRequest(request: URLRequest, method: String, path: String, payload: Data, dateStamp: String, amzDate: String) -> URLRequest {
        var signedRequest = request
        
        let service = "s3"
        let host = URL(string: endpoint)!.host!
        
        // Create canonical request
        let canonicalUri = path
        let canonicalQueryString = ""
        
        let payloadHash = sha256Hash(payload)
        
        let canonicalHeaders = [
            "content-type:\(request.value(forHTTPHeaderField: "Content-Type") ?? "")",
            "host:\(host)",
            "x-amz-content-sha256:\(payloadHash)",
            "x-amz-date:\(amzDate)"
        ].joined(separator: "\n") + "\n"
        
        let signedHeaders = "content-type;host;x-amz-content-sha256;x-amz-date"
        
        let canonicalRequest = [
            method,
            canonicalUri,
            canonicalQueryString,
            canonicalHeaders,
            signedHeaders,
            payloadHash
        ].joined(separator: "\n")
        
        // Create string to sign
        let algorithm = "AWS4-HMAC-SHA256"
        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        let stringToSign = [
            algorithm,
            amzDate,
            credentialScope,
            sha256Hash(canonicalRequest)
        ].joined(separator: "\n")
        
        // Calculate signature
        let signingKey = getSignatureKey(dateStamp: dateStamp, regionName: region, serviceName: service)
        let signature = hmacSHA256(key: signingKey, data: stringToSign).map { String(format: "%02x", $0) }.joined()
        
        // Create authorization header
        let authorization = "\(algorithm) Credential=\(accessKeyId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
        signedRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        return signedRequest
    }
    
    private func getSignatureKey(dateStamp: String, regionName: String, serviceName: String) -> Data {
        let kSecret = "AWS4\(secretAccessKey)".data(using: .utf8)!
        let kDate = hmacSHA256(key: kSecret, data: dateStamp)
        let kRegion = hmacSHA256(key: kDate, data: regionName)
        let kService = hmacSHA256(key: kRegion, data: serviceName)
        let kSigning = hmacSHA256(key: kService, data: "aws4_request")
        return kSigning
    }
    
    private func hmacSHA256(key: Data, data: String) -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: data.data(using: .utf8)!, using: symmetricKey)
        return Data(signature)
    }
    
    private func sha256Hash(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    private func sha256Hash(_ string: String) -> String {
        let data = string.data(using: .utf8)!
        return sha256Hash(data)
    }
    
    private func formatAmzDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    private func formatDateStamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
}

// MARK: - Errors
enum S3UploadError: LocalizedError {
    case imageCompressionFailed
    case invalidResponse
    case uploadFailed(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "图片压缩失败"
        case .invalidResponse:
            return "服务器响应无效"
        case .uploadFailed(let statusCode, let message):
            return "上传失败 (\(statusCode)): \(message)"
        }
    }
}
