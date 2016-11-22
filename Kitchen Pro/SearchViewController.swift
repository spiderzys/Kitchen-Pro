//
//  SearchViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//



import UIKit

enum sortType {
    
    case relevance
    case calorie
}

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var numOfColumns:CGFloat = 3
    var recipes:Array<Recipe> = Array()
    var sortedRecipes:Array<Recipe> = Array()
    
    
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sortedRecipes = recipes
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        
        return sortedRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipe", for: indexPath)
        
        return recipeCell
        
        
        
    }
    
    
    // delegate protocol
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return CGSize(width: collectionView.bounds.width/numOfColumns, height: collectionView.bounds.width/numOfColumns)
        
    }
    
    
    @IBAction func sortMethodChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            sortRecipes(type: .relevance)
        case 1:
            sortRecipes(type: .calorie)
        default:
            break
        }
        
    }
    
    private func sortRecipes(type:sortType){
        
        switch type {
        case .relevance:
            sortedRecipes = recipes
        case .calorie:
            sortedRecipes.sort{ $0.calorie < $1.calorie }
        }
        
    }
    
    
    
}
