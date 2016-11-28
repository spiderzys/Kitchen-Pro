//
//  RecipeViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import BEMCheckBox

class RecipeViewController: UIViewController, UITableViewDataSource, BEMCheckBoxDelegate{
    
    
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var servingLabel: UILabel!
    
    @IBOutlet weak var calorieLabel: UILabel!
    
    @IBOutlet weak var recipeLabel: UILabel!
 
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var ingredientTableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    var recipe:Recipe?
    
    var recipeImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRecipe()
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?){
        if (segue.identifier == "web") {
            
            let recipeWebViewController = segue.destination as! RecipeWebViewController
            recipeWebViewController.recipeTitle = recipe!.title
            recipeWebViewController.recipeUrl = URL(string: recipe!.urlString)
           
        }
    }
    private func setRecipe(){
        let recipes = RecipeStorage.sharedInstance.recipes.objects(Recipe.self).filter("urlString =  %@",recipe!.urlString)
        if recipes.count == 1 {
            recipe = recipes[0]
        }
        servingLabel.text = String(recipe!.serving)
        calorieLabel.text = String(recipe!.calorie)
        recipeLabel.text = "Diet: " + recipe!.dietLabels + "\nHealth: " + recipe!.healthLabels
        titleLabel.text = String(recipe!.source)
        navigationBar.topItem?.title = recipe!.title
        recipeImageView.image = recipeImage
        if recipe!.saved {
            blurSaveButton()
        }
        
    }
    
    private func blurSaveButton(){
        saveButton.alpha = 0.26
    }
    private func clearSaveButton(){
        saveButton.alpha = 1
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     
    */
    
    // table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe!.ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let ingredientCell = tableView.dequeueReusableCell(withIdentifier: "ingredient", for: indexPath)
        let ingredientLabel = ingredientCell.contentView.viewWithTag(11) as! UILabel
        let checkbox = ingredientCell.contentView.viewWithTag(10) as! BEMCheckBox
        let ingredient = recipe!.ingredients[indexPath.row]
        ingredientLabel.text = ingredient.ingredientDescription
        checkbox.setOn(ingredient.prepared, animated: false)
        
        if(indexPath.row % 2 == 0){
            ingredientCell.contentView.backgroundColor = UIColor.white
        }
        else {
            ingredientCell.contentView.backgroundColor = view.backgroundColor
        }
        
        return ingredientCell
    }
    
    @IBAction func didSaveButtonTouched(_ sender: UIButton) {
        
        if recipe!.saved {
            RecipeRequester.sharedInstance.removeRecipes(recipes: [recipe!], type: .saved)
            clearSaveButton()
            
        }
        else {
            RecipeRequester.sharedInstance.addRecipes(recipes: [recipe!], type: .saved)
            blurSaveButton()
        }
        
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
      
        let ingredientCell = checkBox.superview?.superview as! UITableViewCell
        try! RecipeStorage.sharedInstance.recipes.write {
            recipe!.ingredients[ingredientTableView.indexPath(for: ingredientCell)!.row].prepared = !recipe!.ingredients[ingredientTableView.indexPath(for: ingredientCell)!.row].prepared
        }
        
        if (recipe!.saved) {
            
            RecipeRequester.sharedInstance.addRecipes(recipes: [recipe!], type: .saved)
            
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
