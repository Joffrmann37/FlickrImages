//
//  FlickrItemsViewModelTests.swift
//  FlickrImagesTests
//
//  Created by Joffrey Mann on 2/15/24.
//

import XCTest
@testable import FlickrImages
import Combine

final class FlickrItemsViewModelTests: XCTestCase {
    func test_DidGetItemsJSON() {
        let vm = FlickrItemsViewModelSpy(useCase: FetchFlickrItemsUseCase(repository: FlickrItemsRepositorySpy()))
        let exp = expectation(description: "Wait for task")
        let expectedItems = testWithExpectation(vm: vm, exp: exp)
        XCTAssertTrue(expectedItems.count > 0)
    }
    
    func test_CouldNotReadData() {
        let vm = FlickrItemsViewModelSpy(useCase: FetchFlickrItemsUseCase(repository: FlickrItemsRepositorySpy()))
        let exp = expectation(description: "Wait for task")
        let error = testWithExpectationOfError(vm: vm, type: RootInvalidSpy.self, exp: exp)
        XCTAssertEqual(error, vm.error)
    }
    
    func test_InvalidURL() {
        let vm = FlickrItemsViewModelSpy(useCase: FetchFlickrItemsUseCase(repository: FlickrItemsRepositorySpy()), url: URL(string:"https://api.flicr.com/sevices/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=porcupine")!)
        let exp = expectation(description: "Wait for task")
        let error = testWithExpectationOfError(vm: vm, type: RootSpy.self, exp: exp)
        XCTAssertEqual(error, vm.error)
    }
    
    private func testWithExpectation(vm: FlickrItemsViewModelSpy, exp: XCTestExpectation, timeout: Double = 3, file: StaticString = #file, line: UInt = #line) -> [FlickrItem] {
        var itemsToCompare = [FlickrItem]()
        vm.fetchItems()
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            _ = vm.$items.sink { items in
                itemsToCompare = items
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: timeout)
        return itemsToCompare
    }
    
    private func testWithExpectationOfError<T>(vm: FlickrItemsViewModelSpy, type: T.Type, exp: XCTestExpectation, timeout: Double = 3, file: StaticString = #file, line: UInt = #line) -> FLError where T: Root {
        var finalError: FLError!
        vm.fetchItems(type: RootInvalidSpy.self)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            _ = vm.$error.sink { error in
                guard let error = error else { return }
                finalError = error
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: timeout)
        return finalError
    }
    
    private class FlickrItemsViewModelSpy: FlickrItemsViewModel {
        private var subscriptions = Set<AnyCancellable>()
        
        override init(useCase: FetchFlickrItemsUseCase, url: URL = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1")!) {
            super.init(useCase: useCase, url: url)
            self.useCase = useCase
            self.url = url
        }
        
        override func fetchItems<T>(type: T.Type = Root.self) where T: Root  {
            return useCase.fetchItems(url: url, type: type).sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.error = error
                }
            } receiveValue: { [weak self] root in
                guard let self = self else { return }
                self.items = root.items
            }.store(in: &subscriptions)
        }
    }
    
    private class RootSpy: Root {}
    
    private class RootInvalidSpy: RootSpy {
        enum RootKeys: String, CodingKey {
            case items = "itemss"
        }
        required init(from decoder: Decoder) throws {
            try super.init(from: decoder)
            let container = try decoder.singleValueContainer()
            self.items = try container.decode([FlickrItemInvalidSpy].self)
        }
    }
    
    private class FlickrItemInvalidSpy: FlickrItem {
        var dateTaken: String
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: FlickrItemKeys.self)
            self.dateTaken = try container.decode(String.self, forKey: .dateTaken)
            try super.init(from: decoder)
        }
    }
    
    private class FlickrItemsRepositorySpy: Serviceable {
        var subscriptions = Set<AnyCancellable>()
        
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
                        if case .failure(_) = completion {
                            promise(.failure(.badRequest))
                        }
                    }
            receiveValue: {
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
                
            }
        }
    }
}
