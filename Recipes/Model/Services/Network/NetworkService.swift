//
//  NetworkService.swift
//  Recipes
//
//  Created by Aser Eid on 13/08/2024.
//

import Foundation
import Combine
import Alamofire

protocol NetworkServiceProtocol {
    func get<T: Decodable>(endpoint: String, url: String?) -> AnyPublisher<T, Error>
}
class NetworkService: NetworkServiceProtocol {
    func get<T>(endpoint: String, url: String? = Constant.baseURL) -> AnyPublisher<T, Error> where T : Decodable {
        guard let url = url else {
            print(url)
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let fullUrl = url + endpoint
        
        return AF.request(fullUrl)
            .validate()
            .publishDecodable()
            .value()
            .mapError{ $0 as Error }
            .eraseToAnyPublisher()
    }
}
