//
//  API+Requester.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit
import Alamofire

extension API {
    
    private func parse(params: JSON?, response: AFDataResponse<Data>) -> (Swift.Result<T, Error>) {
        let statusCode = response.response?.statusCode ?? 0
        
        let decoder = JSONDecoder()
        
        switch response.result {
        case .success(let data) where statusCode >= 200 && statusCode <= 299:
            do {
                let object = try decoder.decode(T.self, from: data)
                return .success(object)
            } catch {
                print("Error to decode")
            }
            
            return .failure(MUMError.unknown)
            
        case .success(let data):
            do {
                let object = try decoder.decode(MUMError.self, from: data)
                if object.status == 209 {
                    NotificationCenter.default.post(name: NSNotification.Name.init("application_logout"), object: nil)
                }
                guard object.status == 223 || object.status == 228 else { return .failure(object) }
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
                print("Error")
            }
            
            return .failure(MUMError.unknown)
        case .failure(let error):
            if statusCode == 200 {
                if let obj = EmptyResult() as? T {
                    return .success(obj)
                } else if User.self is T.Type, let headers = response.response?.allHeaderFields {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted)
                        let object = try decoder.decode(T.self, from: data)
                        return .success(object)
                    } catch {
                        print("Error to decode")
                    }
                }
            }
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
}
