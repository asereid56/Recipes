//
//  CategoryCollectionViewCell.swift
//  Recipes
//
//  Created by Aser Eid on 13/08/2024.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCellAppearance()
    }
    
    func configure(with text: String, isSelected: Bool){
        categoryTxt.text = text
        self.layer.borderColor = isSelected ? UIColor.purple.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = isSelected ? 2 : 0
    }
    
    private func setUpCellAppearance(){
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }
    
}
