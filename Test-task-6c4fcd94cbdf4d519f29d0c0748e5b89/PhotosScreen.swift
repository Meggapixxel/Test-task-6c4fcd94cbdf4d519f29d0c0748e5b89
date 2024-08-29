//
//  PhotosScreen.swift
//  Test-task-6c4fcd94cbdf4d519f29d0c0748e5b89
//
//  Created by Personal on 29/08/2024.
//

import SwiftUI

struct PhotosScreen: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        PhotoScreen(imageUrl: item.src.original)
                            .navigationTitle(item.photographer)
                    } label: {
                        VStack(spacing: 0) {
                            AsyncImage(url: URL(string: item.src.large)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            
                            Text(item.photographer)
                                .frame(minHeight: 44)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .mask(RoundedRectangle(cornerRadius: 15))
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal, 16)
                    }
                }
                
                if viewModel.nextPage != nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            viewModel.loadNext()
                        }
                        .id(viewModel.page)
                }
            }
        }
        .refreshable {
            viewModel.reload()
        }
        .onAppear {
            viewModel.reload()
        }
        .navigationTitle("Photos (\(viewModel.items.count))")
    }
}

extension PhotosScreen {
    final class ViewModel: ObservableObject {
        let apiClient = APIClient()
        @Published var items = [Photo]()
        private(set) var page = 0
        private(set) var nextPage: Int?
        private var task: Task<Void, Never>?
        
        @MainActor
        func reload() {
            task?.cancel()
            let page = 1
            task = Task {
                defer { self.task = nil }
                do {
                    let response = try await apiClient.getPhotos(page: page)
                    self.page = page
                    self.items = response.photos
                    self.nextPage = response.nextPage
                } catch {
                    // TODO: - error handling
                    print(error)
                }
            }
        }
        
        @MainActor
        func loadNext() {
            guard let page = nextPage else {
                return
            }
            task?.cancel()
            task = Task {
                defer { self.task = nil }
                do {
                    let response = try await apiClient.getPhotos(page: page)
                    self.page = page
                    self.items.append(contentsOf: response.photos)
                    self.nextPage = response.nextPage
                } catch {
                    // TODO: - error handling
                    print(error)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PhotosScreen(viewModel: .init())
    }
}
