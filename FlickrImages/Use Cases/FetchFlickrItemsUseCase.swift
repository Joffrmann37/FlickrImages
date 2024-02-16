//
//  FetchItemsUseCase.swift
//  FlickrImages
//
//  Created by Joffrey Mann on 2/15/24.
//

import Foundation
import Combine

class FetchFlickrItemsUseCase {
    let repository: Serviceable
    
    init(repository: Serviceable) {
        self.repository = repository
    }
    
    func fetchItems<T: Decodable>(url: URL, type: T.Type = Root.self) -> Future<T, FLError> where T: Root  {
        return repository.fetch(url: url, forType: type)
    }
}
