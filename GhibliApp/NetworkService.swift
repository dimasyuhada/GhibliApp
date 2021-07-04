//
//  NetworkService.swift
//  GhibliApp
//
//  Created by macuser on 02/07/2021.
//

import Foundation
import RxSwift

class NetworkService {
    func execute<T: Decodable>(url: URL) -> Observable<T> {
        return Observable.create { observer -> Disposable in
            let task = URLSession.shared.dataTask(with: url) {data, _, _ in
                guard let data = data, let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                    return
                }
                observer.onNext(decoded)
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
