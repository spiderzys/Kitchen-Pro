//
//  ViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
// https://api.edamam.com/search?q=chicken&app_id=ac0ab8e9&app_key=fb39a454934a7a5a74b8adcb3a8b3985&from=0&to=3&calories=gte%20591,%20lte%20722&health=alcohol-free

import UIKit
import BEMCheckBox

class RootViewController: UIViewController, UIScrollViewDelegate, RecipeRequesterDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var recommendedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var savedRecipeCollectionView: UICollectionView!
  
    let recipeRequester = RecipeRequester.sharedInstance
    let observer = NSObject()
    
    var recipeCellSize:CGSize {
        return CGSize(width: recommendedRecipeCollectionView.bounds.height, height: recommendedRecipeCollectionView.bounds.height)
    }
    
    var recommendedRecipes:Array<Recipe> = Array()
    var savedRecipes:Array<Recipe> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRecipes()
        
     //   recipeRequester.recipeSearchRequest(keyword: "beefwewe");
       
       
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
        
    }
    
    func setRecipes(){
        recipeRequester.delegate = self;
        recipeRequester.recipeRequest(type: RecipeRequestType.recommended , searchKey: nil)
        recipeRequester.recipeRequest(type: RecipeRequestType.saved , searchKey: nil)
        // kvo to observe
    
   //     addObserver(self, forKeyPath: #keyPath(recommendedRecipes), options: .new, context: nil)
  //      addObserver(self, forKeyPath: #keyPath(savedRecipes), options: .new, context: nil)
    }
   /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if(keyPath == #keyPath(recommendedRecipes)){
            
            recommendedRecipeCollectionView.reloadData()
        }
        else if (keyPath == #keyPath(savedRecipes)){
            
            savedRecipeCollectionView.reloadData()
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(recommendedRecipes), context: nil)
        removeObserver(self, forKeyPath: #keyPath(savedRecipes), context: nil)
    }
    */
    // RecipeRequester delegate
    
    func didGetRecipes(recipes:Array<Recipe>,type:RecipeRequestType){
        
        switch type {
        case .saved:
            savedRecipes = recipes
            savedRecipeCollectionView.reloadData()
        case .recommended:
            recommendedRecipes = recipes
            recommendedRecipeCollectionView.reloadData()
        default:
            break
            
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
         //  if let cell = collectionView.cellForItem(at: indexPath) {
          //    let imageView = cell.contentView.viewWithTag(100) as! UIImageView
              imageView.image = image
        //    }
            
        })
        
        return recipeCell!
        
    }
    
    
    // collectionView delegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return recipeCellSize
    }
    
    @IBAction func didDeleteButtonTouched(_ sender: UIButton) {
        
        let cell = sender.superview as! UICollectionViewCell
        let indexPath = savedRecipeCollectionView.indexPath(for: cell)!
        savedRecipeCollectionView.deleteItems(at: [indexPath])
        let removedRecipe = savedRecipes[indexPath.row]
        
        savedRecipes.remove(at:indexPath.row)
        RecipeStorage.sharedInstance.removeRecipe(recipe: removedRecipe)
    }
    
    
}

