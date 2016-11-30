//
//  SearchViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//



import UIKit

let numOfRecipesEachRequest = 30

enum sortType:Int {
    
    case relevance = 0
    case calorie = 1
}

class SearchViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate,RecipeRequesterDelegate {
    
    var keyword:String = ""
    var numOfColumns:CGFloat = 2
    var recipes:Array<Recipe> = Array()
    var selectedRecipe:Recipe?
    
    
    @IBOutlet weak var loadingActivityView: UIActivityIndicatorView!
    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBar.text = keyword
        recipeRequester.delegate = self
        searchRecipes();
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?){
        if (segue.identifier == "online") {
            let recipeCell = sender as! UICollectionViewCell
            let imageView = recipeCell.contentView.viewWithTag(10) as! UIImageView
            
            let recipeViewController = segue.destination as! RecipeViewController
            recipeViewController.recipe = selectedRecipe!
            recipeViewController.recipeImage = imageView.image
        }
    }
   
    internal func didGetRecipes(recipes:Array<Recipe>){
        
        if (recipes.count == 0){
            self.recipes = recipes
            sortRecipes(type: sortType(rawValue: self.sortSegmentControl.selectedSegmentIndex)!)
            recipeCollectionView.reloadData()
        }
        
        self.recipes = recipes
        sortRecipes(type: sortType(rawValue: self.sortSegmentControl.selectedSegmentIndex)!)
        recipeCollectionView.reloadData()
    }
    
    
    func didfailToGetRecipe(error:RecipeRequestError){
        recipeCollectionView.isScrollEnabled = true
        loadingActivityView.isHidden = true
        var message = "no (more) recieps for the input"
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
    
    func didGetMoreRecipes(recipes: Array<Recipe>) {
        
        var indexPaths:Array<IndexPath> = Array()
        loadingActivityView.isHidden = true
    
        for i in 0...recipes.count-1 {
            let indexPath = IndexPath(row: self.recipes.count + i, section: 0)
            indexPaths.append(indexPath)
        }
        self.recipes.append(contentsOf: recipes)
        recipeCollectionView.insertItems(at: indexPaths)
        recipeCollectionView.isScrollEnabled = true
        
    }
    
    func searchRecipes(){
        recipeRequester.recipeSearchRequest(keyword: keyword)
    }
    
    func searchMoreRecipes(){
        
        recipeRequester.moreRecipesRequest(keyword: keyword, from: recipes.count)
        
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
        
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipe", for: indexPath)
        let calorieLabel = recipeCell.contentView.viewWithTag(11) as! UILabel
        let servingLabel = recipeCell.contentView.viewWithTag(12) as! UILabel
        let imageView = recipeCell.contentView.viewWithTag(10) as! UIImageView
        let recipe = recipes[indexPath.row]
        calorieLabel.text = String(recipe.calorie)
        servingLabel.text = String(recipe.serving)
        imageView.image = nil
        let random = Int(arc4random_uniform(11))
        if random > 9 {
            DispatchQueue.main.async {
                let recipes = RecipeStorage.sharedInstance.recipes.objects(Recipe.self).filter("urlString =  %@",recipe.urlString)
                if recipes.count != 0 {
                    RecipeRequester.sharedInstance.addRecipes(recipes: [recipes[0]], type: .recommended)
                }
                else{
                    RecipeRequester.sharedInstance.addRecipes(recipes: [recipe], type: .recommended)
                }
            }
        }
        ImageLoader.sharedInstance.loadImage(url: URL(string: recipe.imageUrlString)!, completion: {image in
            imageView.image = image
        })
        
        return recipeCell
        
    }
    
    
    // colletionview delegate protocol
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        selectedRecipe = recipes[indexPath.row]
        let recipeCell = collectionView.cellForItem(at: indexPath)
        performSegue(withIdentifier: "online", sender: recipeCell)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return CGSize(width: collectionView.bounds.width/numOfColumns, height: collectionView.bounds.width/numOfColumns*124/108)
        
    }
    

    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cellHeight = scrollView.bounds.width/numOfColumns*124/108
        let height = cellHeight * CGFloat(recipes.count)/numOfColumns;
        
        if (scrollView.contentOffset.y + 500 > height) {
            loadingActivityView.isHidden = false
            scrollView.isScrollEnabled = false
            recipeRequester.moreRecipesRequest(keyword: keyword, from: recipes.count)
        }
      
    }
    
    
    // segment value changed
    @IBAction func sortMethodChanged(_ sender: UISegmentedControl) {
        
        sortRecipes(type: sortType(rawValue: sender.selectedSegmentIndex)!)
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: {
            RecipeRequester.sharedInstance.removeIdleRecipes()
            
        })
        
    }
    
    // searchbar delegate currently not available
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        guard let key = searchBar.text else{
            return
        }
        keyword = key
        searchRecipes()
    }
    
   
    private func sortRecipes(type:sortType){
        
        switch type {
        case .relevance:
            recipes.sort{ $0.ingredients.count < $1.ingredients.count }
        case .calorie:
            recipes.sort{ $0.calorie < $1.calorie }
        }
        self.recipeCollectionView.reloadData()
    }
}
