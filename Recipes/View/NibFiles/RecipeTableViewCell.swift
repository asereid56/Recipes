//
//  RecipeTableViewCell.swift
//  Recipes
//
//  Created by Aser Eid on 14/08/2024.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeSource: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        recipeImage.layer.cornerRadius = 10
        recipeImage.layer.masksToBounds = true
    }
    
    func configure(with recipe: Recipe) {
        recipeName.text = recipe.label
        recipeSource.text = recipe.source
        
        if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
            recipeImage.kf.setImage(with: url , placeholder: UIImage(named: "placeholder"))
        }
    }
}
