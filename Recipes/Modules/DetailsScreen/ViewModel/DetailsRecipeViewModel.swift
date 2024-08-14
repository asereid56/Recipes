//
//  DeatilsRecipeViewModel.swift
//  Recipes
//
//  Created by Aser Eid on 14/08/2024.
//

import Foundation
import Combine

class DetailsRecipeViewModel {
    private let network : NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    var url = ""
    @Published var recipeDetails : Recipe?
    
    init(network: NetworkServiceProtocol) {
        self.network = network
    }
    
    func fetchData(){
        network.get(endpoint: "", url: url).sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
            }
        } receiveValue: { (data: RecipeResponse) in
            self.recipeDetails = data.recipe
        }
        .store(in: &cancellables)
    }
}
