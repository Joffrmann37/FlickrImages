//
//  DetailView.swift
//  FlickrImages
//
//  Created by Joffrey Mann on 2/15/24.
//

import SwiftUI

struct DetailView: View {
    let imageItem: ImageItem
    var item: FlickrItem
    private let published: String
    @State private var isAnimating = false
    
    init(imageItem: ImageItem, item: FlickrItem, published: String) {
        self.imageItem = imageItem
        self.item = item
        self.published = published
    }
    
    var body: some View {
        NavigationView {
            VStack (spacing: 20, content: {
                ImageItem(item: item)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .onAppear() {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            isAnimating = true
                        }
                    }
                Text("Title: \(item.title)")
                Text("Description: \(item.description)")
                Text("Author: \(item.author)")
                Text("Date: \(published)")
            }).padding(.top, -200)
        }
        .navigationTitle(item.title)
    }
}
