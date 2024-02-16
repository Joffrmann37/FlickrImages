//
//  FlickrItemsViewModel.swift
//  FlickrImages
//
//  Created by Joffrey Mann on 2/15/24.
//

import Foundation
import Combine

class FlickrItemsViewModel: ObservableObject {
    var useCase: FetchFlickrItemsUseCase
    private var subscriptions = Set<AnyCancellable>()
    var url: URL = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1")!
    @Published var items = [FlickrItem]()
    @Published var error: FLError?
    @Published var searchText: String = "" {
        didSet {
            fetchItems()
        }
    }
    var filteredItems: [FlickrItem] {
        get {
            guard !searchText.isEmpty else { return items }
            return items.filter { item in
                item.tags.lowercased().contains(searchText.lowercased())
            }
        }
        set { items = newValue }
    }
    
    init(useCase: FetchFlickrItemsUseCase, url: URL = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1")!) {
        self.useCase = useCase
        self.url = url
    }
    
    private func getURL() -> URL {
        return URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(searchText)")!
    }
        
    func fetchItems<T>(type: T.Type = Root.self) where T: Root {
        useCase.fetchItems(url: getURL()).sink { [unowned self] completion in
            if case let .failure(error) = completion {
                self.error = error
            }
        } receiveValue: { [weak self] root in
            guard let self = self else { return }
            self.items = root.items
        }.store(in: &subscriptions)
    }
}
