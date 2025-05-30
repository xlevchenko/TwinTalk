//
//  NetworkService.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 29.05.2025.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    private let urlString = "https://run.mocky.io/v3/83dc79dc-d16b-42a2-beda-05c7072a0937"
    
    func fetchSessions() async throws -> [Session] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode([Session].self, from: data)
    }
}
