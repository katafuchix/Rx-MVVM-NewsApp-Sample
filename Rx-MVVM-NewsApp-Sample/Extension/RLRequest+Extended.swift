//
//  RLRequest+Extended.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2022/06/18.
//

import Foundation
import RxSwift
import RxCocoa

struct Resource<T: Decodable> {
    let url: URL
}

extension URLRequest {
    static func load<T>(resource: Resource<T>) -> Observable<T> {
        return Observable.just(resource.url)
            .flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
                let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy,
                                         timeoutInterval: 5.0)
                return URLSession.shared.rx.response(request: request)
        }
        .map { response, data in
            print("response: \(response.statusCode)")
            return try JSONDecoder().decode(T.self, from: data)
        }
        .asObservable()
    }
}
