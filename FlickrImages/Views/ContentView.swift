//
//  ContentView.swift
//  FlickrImages
//
//  Created by Joffrey Mann on 2/15/24.
//

import SwiftUI

struct ImageItem: View {
    @State var item: FlickrItem
    
    var body: some View {
        AsyncImage(url: URL(string: $item.wrappedValue.media.m)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: UIScreen.main.bounds.width/3, height: 150)
    }
}

struct ContentView: View {
    @ObservedObject var vm = FlickrItemsViewModel(useCase: FetchFlickrItemsUseCase(repository: FlickrItemsRepository()))
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let height: CGFloat = 150
    
    func getDate(item: FlickrItem) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-d'T'HH:mm:ss'Z'"
        guard let date = dateFormatter.date(from: item.published) else {
            return "N/A"
        }
        dateFormatter.dateFormat = "MMMM d yyyy h:mm 'AM'"
        let str = dateFormatter.string(from: date)
        return str
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach($vm.items) { item in
                        let imageItem = ImageItem(item: item.wrappedValue)
                        NavigationLink(destination: DetailView(imageItem: imageItem, item: item.wrappedValue, published: getDate(item: item.wrappedValue))) {
                            VStack(spacing: 0, content: {
                                imageItem
                            })
                        }
                        .navigationBarTitle("Flickr Images")
                    }
                }
                .padding()
            }
        }
        .searchable(text: $vm.searchText)
        .onAppear {
            if $vm.items.count == 0 {
                vm.fetchItems()
            }
        }
    }
}

#Preview {
    ContentView()
}
