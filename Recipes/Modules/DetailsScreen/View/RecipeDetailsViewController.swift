//
//  RecipeDetailsViewController.swift
//  Recipes
//
//  Created by Aser Eid on 14/08/2024.
//

import UIKit
import Combine
import Kingfisher

class RecipeDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var caloriesAndWeightTxt: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var recipeName: UILabel!
    
    
    var viewModel : DetailsRecipeViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchData()
        
        viewModel?.$recipeDetails
            .receive(on: DispatchQueue.main)
            .sink{ [weak self ] recipe in
                self?.recipeName.text = recipe?.label
                self?.totalTime.text = String(recipe?.totalTime ?? 0)
                
                if let urlString = recipe?.images?.regular?.url, let url = URL(string: urlString) {
                    self?.recipeImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
                }
                self?.caloriesAndWeightTxt.text = "\(String(format: "%.2f", recipe?.calories ?? 0)) / \(String(format: "%.2f", recipe?.totalWeight ?? 0))"
                
                
                
            }.store(in: &cancellables)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
