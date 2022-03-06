//
//  API+Requester.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit
import Alamofire
import DataCache

extension API {
    
    private func logIfNeeded(params: JSON? = nil, response: AFDataResponse<Data>) {
        Logger.log(.networking, info: "SENT (\(self.method.rawValue): \(self.url)) \nHEADERS:\(headers.dictionary)", object: "\n\(String(describing: params))")
        if let data = response.data {
            if data.count > 1024 * 1024 {
                Logger.log(.networking, info: "RECEIVED", object: ">> Large data <<")
            } else {
                Logger.log(.networking, info: "RECEIVED", object: "\n\(String(data: data, encoding: .utf8) ?? "")")
            }
        }
    }
    
    private func parse(params: JSON?, response: AFDataResponse<Data>) -> (Swift.Result<T, Error>) {
        let statusCode = response.response?.statusCode ?? 0
        
        let decoder = JSONDecoder()
        
        switch response.result {
        case .success(let data) where statusCode >= 200 && statusCode <= 299:
            do {
                if case .sectionsFeed = self,
                   let dict = try JSONSerialization.jsonObject(with: data, options: []) as? JSON,
                   let json = dict["result"] as? [JSON] {
                    Defaults.shared.sectionsFeed = json
                }
                if let object = try decoder.decode(FKDataResults<T>.self, from: data).results {
                    return .success(object)
                }
            } catch {
                #if DEBUG
                Logger.log(
                    .custom("🖥 (Parser)"),
                    info: "1️⃣ \(String(describing: FKDataResults<T>.self))",
                    object: "\n\(error.localizedDescription)"
                )
                #endif
            }
            
            do {
                if let object = try decoder.decode(FKDataResult<T>.self, from: data).result {
                    return .success(object)
                }
            } catch {
                #if DEBUG
                Logger.log(
                    .custom("🖥 (Parser)"),
                    info: "2️⃣ \(String(describing: FKDataResult<T>.self))",
                    object: "\n\(error.localizedDescription)"
                )
                #endif
            }
            
            do {
                let object = try decoder.decode(T.self, from: data)
                return .success(object)
            } catch {
                #if DEBUG
                Logger.log(
                    .custom("🖥 (Parser)"),
                    info: "3️⃣ \(String(describing: T.self))",
                    object: "\n\(error.localizedDescription)"
                )
                #endif
            }
            
            return .failure(FKError.unknown)
            
        case .success(let data):
            do {
                let object = try decoder.decode(FKError.self, from: data)
                if object.code == 209 {
                    NotificationCenter.default.post(name: NSNotification.Name.init("application_logout"), object: nil)
                }
                guard object.code == 223 || object.code == 228 else { return .failure(object) }
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
                    let error = dict?["error"] as? String
                    guard let data = error?.data(using: .utf8) else { return .failure(object) }
                    let object = try decoder.decode(T.self, from: data)
                    return .success(object)
                } catch {
                    return .failure(object)
                }
            } catch {
                #if DEBUG
                Logger.log(
                    .custom("🖥 (Parser)"),
                    info: "1️⃣ \(String(describing: FKError.self))",
                    object: "\n\(error.localizedDescription)"
                )
                #endif
            }
            
            return .failure(FKError.unknown)
        case .failure(let error):
            return .failure(error)
        }
    }
        
    @discardableResult
    public func request(params: JSON? = nil, timeout: TimeInterval = 60, progress: ((Progress) -> Void)? = nil, completion: ((Swift.Result<T, Error>) -> Void)? = nil) -> DataRequest {
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers.dictionary
        request.timeoutInterval = timeout
        
        let alamofireRequest = AF.request(url,
                                          method: method,
                                          parameters: params,
                                          encoding: encoding,
                                          headers: headers)
        
        guard let progress = progress else {
            alamofireRequest
                .validate(statusCode: 200...600)
                .responseData(
                    completionHandler: { response in
                        self.logIfNeeded(params: params, response: response)
                        print(response)
                        if let completion = completion {
                            let result = self.parse(params: params, response: response)
                            DispatchQueue.main.async { completion(result) }
                        }
                    }
                )
            
            return alamofireRequest
        }
        
        alamofireRequest
            .downloadProgress(queue: .main, closure: { prog in
                progress(prog)
            })
        
        return alamofireRequest
        
    }
    
    public func upload(data: Data, completion: ((Swift.Result<T, Error>) -> Void)? = nil) {
        var headerNew = self.headers
        
        switch self {
        case .uploadFile(_, let mime):
            headerNew["Content-Type"] = mime ?? "image/png"
        default:
            headerNew["Content-Type"] = "image/png"
        }
        
        AF.upload(data, to: url, headers: headerNew)
            .validate()
            .responseData { response in
                self.logIfNeeded(params: nil, response: response)
                if let completion = completion {
                    let result = self.parse(params: nil, response: response)
                    DispatchQueue.main.async { completion(result) }
                }
        }
    }
}
