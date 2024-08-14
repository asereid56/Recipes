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
    
    func configure(with text: String){
        categoryTxt.text = text
    }
    
    private func setUpCellAppearance(){
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }

}
