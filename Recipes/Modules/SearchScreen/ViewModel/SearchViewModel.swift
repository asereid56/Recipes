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
        } receiveValue: { [weak self] (data: SearchResponse) in
            self?.recipes = data.hits ?? []
            self?.nextURL = data.links?.next.href
        }
        .store(in: &cancellables)
    }
    
    func loadMoreData(){
        guard let nextURL = nextURL else { return }
        networkService.get(endpoint: "", url: nextURL).sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
            }
        } receiveValue: { [weak self] (data: SearchResponse) in
            self?.recipes.append(contentsOf: data.hits ?? [])
            self?.nextURL = data.links?.next.href
        }
        .store(in: &cancellables)
    }
    
    func makeAllURL(filters: [String]) -> String {
        guard !filters.isEmpty else { return String() }
        
        let filterResult: String = filters.joined(separator: "&")
        return "&\(filterResult)"
    }
}
