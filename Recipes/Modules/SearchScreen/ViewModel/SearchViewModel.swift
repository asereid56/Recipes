//
//  SearchViewModel.swift
//  Recipes
//
//  Created by Aser Eid on 13/08/2024.
//

import Foundation
import Combine

class SearchViewModel {
    private let networkService : NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published var recipes: [Recipe] = []
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchData(endpoint: String) {
        networkService.get(endpoint: endpoint, url: Constant.baseURL).sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
                self.recipes = []
            }
        } receiveValue: { (data: SearchResponse) in
            self.recipes = data.hits?.compactMap { $0.recipe } ?? []
        }
        .store(in: &cancellables)
    }
    
    func makeAllURL(fields: [String]?, healths: [String]?) -> String {
        var filedsResult: String = ""
        var healthResult: String = ""
        if let fields = fields {
            for field in fields {
                filedsResult += "&field=\(field)"
            }
        }
        if let healths = healths {
            for health in healths {
                healthResult += "&health=\(health)"
            }
        }
        return filedsResult + healthResult
    }
}
