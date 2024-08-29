//
//  APIClient.swift
//  Test-task-6c4fcd94cbdf4d519f29d0c0748e5b89
//
//  Created by Personal on 29/08/2024.
//

import Foundation

struct APIClient {
    enum Error: Swift.Error {
        case badUrl
    }

    func getPhotos(page: Int) async throws -> PhotosResponse {
        let perPage = 35
        guard let url = URL(string: "https://api.pexels.com/v1/curated?page=\(page)&per_page=\(perPage)") else {
            throw Error.badUrl
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "XXXXXX"
        ]
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apiResponse = try decoder.decode(PhotosAPIResponse.self, from: data)
        return PhotosResponse(
            nextPage: apiResponse.perPage < perPage ? nil : (page + 1),
            photos: apiResponse.photos
        )
    }
}

struct PhotosAPIResponse: Decodable {
    let page: Int
    let perPage: Int
    let nextPage: String?
    let photos: [Photo]
}

struct PhotosResponse {
    let nextPage: Int?
    let photos: [Photo]
}

struct Photo: Decodable, Identifiable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String
    let liked: Bool
    let alt: String
    
    struct Src: Decodable {
        let original: String
        let large: String
    }
    let src: Src
}
