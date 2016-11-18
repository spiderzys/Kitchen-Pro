//
//  RecipeCollectionView.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

protocol RecipeCollectionViewDelegate:UICollectionViewDelegate {
    
    func numOfColumns(collectionView: UICollectionView) -> Int;
}


class RecipeCollectionView: UICollectionView {
    
    weak var recipeCollectionViewDelegate:RecipeCollectionViewDelegate?
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension RecipeCollectionViewDelegate {
    func numOfColumns(collectionView: UICollectionView) -> Int {
        return 3
    }
}
