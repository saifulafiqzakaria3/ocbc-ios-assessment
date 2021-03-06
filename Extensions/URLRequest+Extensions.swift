//
//  URLRequest+Extensions.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 10/04/2022.
//

import Foundation
import RxSwift
import RxCocoa

//Make it generic so that it can be used by other class who conforms to decodable protocol
struct Resource<T: Decodable> {
    let url: URL
    let parameter: [String: Any]?
}

extension URLRequest {
    static func load<T>(resource: Resource<T>) -> Observable<T> {
        return Observable.just(resource.url).flatMap { url -> Observable<Data> in
            var request = URLRequest(url: url)
            let token = UserDefaults.standard.string(forKey: "appToken")
            request.setValue(token, forHTTPHeaderField: "Authorization")
            return URLSession.shared.rx.data(request: request)
        }.map { data -> T in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }

    static func postWithParamaters<T>(resource: Resource<T>) -> Observable<T> {
        guard let param = resource.parameter else { return Observable.empty() }
        
        return Observable.just(resource.url).flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            //status code is 200..<300 and only then return data, if not then it will throw an error
            return URLSession.shared.rx.response(request: request)
        }.map { (response, data) -> T in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
    
//    static func post<T>(resource: Resource<T>) -> Observable<T> {
//        guard let param = resource.parameter else { return Observable.empty() }
//
//        return Observable.just(resource.url).flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
//
//            return URLSession.shared.rx.response(request: request)
//        }.map { (response, data) -> T in
//            print("Response: ", response)
//            if response.statusCode >= 300 {
//                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
//                    print("Failure Response: \(json["error"])")
//                }
//            }
//            return try JSONDecoder().decode(T.self, from: data)
//        }
//    }
}



