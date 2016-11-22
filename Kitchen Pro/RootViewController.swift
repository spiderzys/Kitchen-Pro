//
//  ViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
// https://api.edamam.com/search?q=chicken&app_id=ac0ab8e9&app_key=fb39a454934a7a5a74b8adcb3a8b3985&from=0&to=3&calories=gte%20591,%20lte%20722&health=alcohol-free

import UIKit
import RealmSwift
import GoogleMobileAds

class RootViewController: ViewController, RecipeRequesterDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var recommendedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var savedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let recipeRequester = RecipeRequester.sharedInstance
    var selectedRecipe:Recipe?
    
    var recipeCellSize:CGSize {
        return CGSize(width: recommendedRecipeCollectionView.bounds.height, height: recommendedRecipeCollectionView.bounds.height)
    }
    
    var recommendedRecipes:Results<Recipe> = RecipeRequester.sharedInstance.recommendedRecipes
    var savedRecipes:Results<Recipe> = RecipeRequester.sharedInstance.savedRecipes
    var searchRecipes:Array<Recipe> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.rootViewController = self
        
        let ADrequest = GADRequest()
        bannerView.load(ADrequest)
        setRecipes()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?){
        if segue.identifier == "search" {
            let searchViewController = segue.destination as! SearchViewController
            searchViewController.recipes = searchRecipes
        }
        else if segue.identifier == "local" {
            let recipeCell = sender as! UICollectionViewCell
            let imageView = recipeCell.contentView.viewWithTag(100) as! UIImageView
            let recipeViewController = segue.destination as! RecipeViewController
            recipeViewController.recipe = selectedRecipe
            recipeViewController.recipeImage = imageView.image
        }
    }
    
    private func setRecipes(){
        recipeRequester.delegate = self;
        if recommendedRecipes.count == 0 {
            recipeRequester.recipeRequest(type: .recommended, searchKey: nil)
        }
        
    }
    
    
    internal func didGetRecipes(recipes:Array<Recipe>){
        
        DispatchQueue.main.async {
            self.searchRecipes = recipes
            self.performSegue(withIdentifier: "search", sender: nil)
        }
    }
    
    internal func didUpdateRecipes(type: RecipeType) {
        DispatchQueue.main.async {
            switch type {
            case .saved:
                self.savedRecipeCollectionView.reloadData()
            case .recommended:
                self.recommendedRecipeCollectionView.reloadData()
            }
        }
    }
    
    
    
    // collectionView data source
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        return (collectionView == recommendedRecipeCollectionView) ? recommendedRecipes.count : savedRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        var recipeCell:UICollectionViewCell?
        var recipe:Recipe?
        
        if (collectionView == recommendedRecipeCollectionView){
            
            recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "guess", for: indexPath)
            recipe = recommendedRecipes[indexPath.row]
            
        }
            
        else{
            
            recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "save", for: indexPath)
            recipe = savedRecipes[indexPath.row]
        }
        
        
        let titleLabel = recipeCell!.contentView.viewWithTag(101) as! UILabel
        titleLabel.text = recipe?.title
        
        let imageView = recipeCell!.contentView.viewWithTag(100) as! UIImageView
        
        
        
        imageView.image = nil
        ImageLoader.sharedInstance.loadImage(url: URL(string: recipe!.imageUrlString)!, completion: {image in
            imageView.image = image
        })
        
        return recipeCell!
        
    }
    
    
    // collectionView delegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
    
        if (collectionView == recommendedRecipeCollectionView){
              selectedRecipe = recommendedRecipes[indexPath.row]
        }
        else{
            selectedRecipe = savedRecipes[indexPath.row]
        }

        let recipeCell = collectionView.cellForItem(at: indexPath)
       
        performSegue(withIdentifier: "local", sender: recipeCell)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return recipeCellSize
    }
    
    
    // search bar delegate
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        guard let key = searchBar.text else{
            return
        }
        recipeRequester.recipeRequest(type: .search, searchKey: key)
    }
    
    
    @IBAction func didDeleteButtonTouched(_ sender: UIButton) {
        
        let recipeCell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = savedRecipeCollectionView.indexPath(for: recipeCell)!
        recipeRequester.removeRecipes(recipes: [savedRecipes[indexPath.row]], type: .saved)
        
    }
    
    
}

