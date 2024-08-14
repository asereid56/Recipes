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
    @Published var recipes: [Hit] = []
    private var nextURL: String?
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchData(endpoint: String, url: String) {
        networkService.get(endpoint: endpoint, url: url).sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
                self.recipes = []
            }
        } receiveValue: { (data: SearchResponse) in
            self.recipes.append(contentsOf: data.hits ?? [])
            self.nextURL = data.links?.next.href
        }
        .store(in: &cancellables)
    }
    
    func loadMoreData(){
        guard let nextURL = nextURL else { return }
        fetchData(endpoint: "", url: nextURL)
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
