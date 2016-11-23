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

class RootViewController: ViewController, RecipeRequesterDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var recommendedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var savedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let recipeRequester = RecipeRequester.sharedInstance
    var selectedRecipe:Recipe?
    
    
    var recipeCellSize:CGSize {
        return CGSize(width: recommendedRecipeCollectionView.bounds.height, height: recommendedRecipeCollectionView.bounds.height)
    }
    let recommendedRecipes = RecipeRequester.sharedInstance.recommendedRecipes
    let savedRecipes = RecipeRequester.sharedInstance.savedRecipes
    var searchRecipes:Array<Recipe> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBanner()
        setRecipes()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        recommendedRecipeCollectionView.reloadData()
        savedRecipeCollectionView.reloadData()
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
    
    private func loadBanner(){
        bannerView.rootViewController = self
        
        let ADrequest = GADRequest()
        bannerView.load(ADrequest)
    }
    
    private func setRecipes(){
        recipeRequester.delegate = self;
        if recommendedRecipes.count == 0 {
            recipeRequester.recipeRequest(type: .recommended, searchKey: nil)
        }
        
    }
    
    
    internal func didGetRecipes(recipes:Array<Recipe>,type:RecipeRequestType){
        
        switch type {
        case .search:
            DispatchQueue.main.async {
                self.searchRecipes = recipes
                self.performSegue(withIdentifier: "search", sender: nil)
            }
        case .recommended:
            recommendedRecipeCollectionView.reloadData()
        case .saved:
            savedRecipeCollectionView.reloadData()
            
        }
        
        
    }
    
    
    func didfailToGetRecipe(error:RecipeRequestError){
        var message = "No return, check your input and network "
        switch error {
        case .response_error:
           message = "no network"
        case .hits_error:
           message = "no return for these ingredients"
        default:
            break
        }
        showAlert(message: message)
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
    }
    
    
    @IBAction func didDeleteButtonTouched(_ sender: UIButton) {
        
        let recipeCell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = savedRecipeCollectionView.indexPath(for: recipeCell)!
        recipeRequester.removeRecipes(recipes: [savedRecipes[indexPath.row]], type: .saved)
        savedRecipeCollectionView.reloadData()
    }
    

    
    
}

