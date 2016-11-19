//
//  ViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
// https://api.edamam.com/search?q=chicken&app_id=ac0ab8e9&app_key=fb39a454934a7a5a74b8adcb3a8b3985&from=0&to=3&calories=gte%20591,%20lte%20722&health=alcohol-free

import UIKit

class RootViewController: UIViewController, UIScrollViewDelegate, RecipeRequesterDelegate {

    @IBOutlet weak var recommededRecipeCollectionView: UICollectionView!
    @IBOutlet weak var savedRecipeCollectionView: UICollectionView!
  
    let recipeRequester = RecipeRequester.sharedInstance
    
    var recipeCellSize:CGSize {
        return CGSize(width: recommededRecipeCollectionView.bounds.height, height: recommededRecipeCollectionView.bounds.height)
    }
    
    var recommendedRecipes:Array<Recipe> = Array()
    var savedRecipes:Array<Recipe> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
     //   recipeRequester.recipeSearchRequest(keyword: "beefwewe");
       
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if(keyPath == #keyPath(recommendedRecipes)){
            
            recommededRecipeCollectionView.reloadData()
        }
        
        else if (keyPath == #keyPath(savedRecipes)){
            
            savedRecipeCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                 sender: Any?){
        
    }
    
    func setRecipes(){
        recipeRequester.delegate = self;
        recipeRequester.recipeRecommededRequest()
        
        // kvo to observe 
        self.addObserver(self, forKeyPath: #keyPath(recommendedRecipes), options: .new, context: nil)
        self.addObserver(self, forKeyPath: #keyPath(savedRecipes), options: .new, context: nil)
    }
    
    
    // RecipeRequester delegate
    func didGetQuesRecipes(recipes:Array<Recipe>){
        
    }
    
    func didGetRecommendedRecipes(recipes:Array<Recipe>){
        
        recommendedRecipes = recipes;
        recommededRecipeCollectionView.reloadData()
    }
    
    func didGetSavedRecipes(recipes:Array<Recipe>){
        
        savedRecipeCollectionView.reloadData()
    }

    
    // data source protocol
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        if (collectionView == recommededRecipeCollectionView){
            let recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "guess", for: indexPath)
            
            return recipeCell
        }
        
        else{
            let recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "save", for: indexPath)
            
            return recipeCell
        }
        
    }
    
    
    // delegate protocol
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return recipeCellSize
    }
}

