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

class RootViewController: ViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var recommendedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var savedRecipeCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var optionView: UIView!
    
    @IBOutlet weak var OptionButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!


    
    
    var selectedRecipe:Recipe?
    
    
    var recipeCellSize:CGSize {
        return CGSize(width: recommendedRecipeCollectionView.bounds.height, height: recommendedRecipeCollectionView.bounds.height)
    }
    let recommendedRecipes = RecipeRequester.sharedInstance.recommendedRecipes
    let savedRecipes = RecipeRequester.sharedInstance.savedRecipes

    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if PRO
            setSwitches()
        #else
            loadBanner()
            OptionButton.isHidden = true
        #endif
     //   loadBanner()
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
            searchViewController.keyword = (searchBar.text?)!
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
            recipeRequester.resetRecommendedRecipes(completion: recommendedRecipeCollectionView.reloadData())
            
        }
        
    }
    
    private func setSwitches() {
        for i in 0...7 {
            let filterSwitch = view.viewWithTag(20+i) as! UISwitch
            filterSwitch.isOn = (UserDefaults.standard.value(forKey: String(i)) != nil)
            
            filterSwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            
        }
    }
    
  
    func switchChanged(sender:UISwitch) {
        let key = String(sender.tag - 20)
        if (sender.isOn){
            UserDefaults.standard.set(true, forKey: key)
        }
        else {
            UserDefaults.standard.removeObject(forKey: key )
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
      
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "search", sender: nil)
        }
        
       // recipeRequester.recipeRequest(type: .search, searchKey: key)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
    }

    
    @IBAction func didDeleteButtonTouched(_ sender: UIButton) {
        
        let recipeCell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = savedRecipeCollectionView.indexPath(for: recipeCell)!
        let alertController = UIAlertController(title: nil, message:String(format: "Remove recipe: %@", savedRecipes[indexPath.row].title), preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(actionCancel)
        let actionOk = UIAlertAction.init(title: "Ok", style: .destructive, handler: {(action) in
            self.recipeRequester.removeRecipes(recipes: [self.savedRecipes[indexPath.row]], type: .saved)
            self.savedRecipeCollectionView.reloadData()
        })
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    

    @IBAction func didOptionShowButtonTouched(_ sender: UIButton) {
      
        
        UIView.transition(with: optionView, duration: 0.5, options: .transitionCurlDown, animations: {
            self.optionView.isHidden = false
            }, completion: nil)
        
        
        
    }
    
    @IBAction func didOptionHideButtonTouched(_ sender: UIButton) {
        UIView.transition(with: optionView, duration: 0.5, options: .transitionCurlUp, animations: {
            self.optionView.isHidden = true
        }, completion: nil)
     
    }
    
    
}

