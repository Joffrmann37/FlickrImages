//
//  FlickrItemsRepository.swift
//  FlickrImages
//
//  Created by Joffrey Mann on 2/15/24.
//

import Foundation
import Combine

enum FLError: Int, Swift.Error {
    case badRequest = 400
    case forbidden = 403
    case notFound = 404
    case serverError = 500
    case notAcceptable = 406
}

protocol Serviceable {
    func fetch<T>(url: URL, forType type: T.Type) -> Future<T, FLError> where T : Decodable
}

class FlickrItemsRepository {
    var subscriptions = Set<AnyCancellable>()
}

extension FlickrItemsRepository: Serviceable {
    func fetch<T>(url: URL, forType type: T.Type) -> Future<T, FLError> where T : Decodable {
        return Future<T, FLError> { [unowned self] promise in
            URLSession(configuration: .default).dataTaskPublisher(for: url)
                .tryMap { (data: Data, response: URLResponse) in
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
                        throw FLError(rawValue: httpResponse.statusCode)!
                    }
                    return data
                }
                .decode(type: type,
                        decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case let .failure(error) = completion, let error = error as? FLError {
                        promise(.failure(error))
                    }
                }
        receiveValue: {
            promise(.success($0))
        }
        .store(in: &self.subscriptions)
            
        }
    }
}
