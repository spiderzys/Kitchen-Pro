//
//  RecipeRequester.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

protocol RecipeRequesterDelegate:class {
    
    func didGetRecipes(recipes:Array<Recipe>,type:RecipeRequestType)
    
    func didfailToGetRecipe(error:RecipeRequestError)
    
    
}

enum RecipeRequestError:String {
    case key_null = "no input for search"
    case response_error = "no response"
    case hits_error = "invaild return"
    case recipes_null = "no recipes found"
}


enum RecipeRequestType {
    
    case saved
    case recommended
    case search
}

enum RecipeType:String {
    
    case saved = "saved"
    case recommended = "recommended"
    
}

class RecipeRequester {
    let recommendedRecipes = RecipeStorage.sharedInstance.recipes.objects(Recipe.self).filter("recommended == true")
    let savedRecipes = RecipeStorage.sharedInstance.recipes.objects(Recipe.self).filter("saved == true")
    let removeRecipes = RecipeStorage.sharedInstance.recipes.objects(Recipe.self).filter("saved == false AND recommended == false")
    
    static let sharedInstance = RecipeRequester()
    let apikey = "app_id=ac0ab8e9&app_key=fb39a454934a7a5a74b8adcb3a8b3985"
    let searchBaseString =  "https://api.edamam.com/search?"
    weak var delegate:RecipeRequesterDelegate?
    var filter = ""
    
    
    // MARK: for search request
    
    func recipeRequest(type:RecipeRequestType, searchKey:String?){
        guard delegate != nil else {
            
            print("no delegate set yet")
            return
        }
        
        switch type {
        case .search:
            recipeSearchRequest(keyword: searchKey, search:true)
        default:
            recipeRecommededRequest()
        }
    }
    
    private func recipeSearchRequest(keyword:String!, search:Bool){
        
        recipeSearchRequest(keyword: keyword, from: 0, to: 100, search:search)
        
    }
    
    private func recipeSearchRequest(keyword:String? , from:Int , to:Int, search:Bool){
        
        if keyword == nil || keyword?.characters.count == 0  {
            
            delegate?.didfailToGetRecipe(error: RecipeRequestError.key_null)
            return
        }
        
        let requestString = String(format: "%@%@&from=%d&to=%d&q=%@", searchBaseString,apikey,from,to,modifiedKeyword(keyword: keyword!))
        
        recipeRequest(url: requestString, search:search)
        
        
        
    }
    
    
    
    private func modifiedKeyword(keyword:String) -> String {
        
        // var key = keyword.replacingOccurrences(of: ",", with: "+");
        return keyword.replacingOccurrences(of: " ", with: "-")
        
    }
    
    
    private func recipeRequest(url:URLConvertible, search:Bool){
        
        Alamofire.request(url).responseJSON { response in
            
            guard let JSON = response.result.value as? [String:AnyObject]  else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.response_error)
                return
            }
            
            guard let rawRecipeDicts = JSON["hits"] as? Array<[String:AnyObject]> else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.hits_error)
                return
            }
            
            guard rawRecipeDicts.count > 0 else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.recipes_null)
                return
            }
            
            
            let recipes = self.processDownloadedRecipes(rawRecipeDicts: rawRecipeDicts)
            
            if(!search){
                
                self.addRecipes(recipes: recipes, type: .recommended)
                self.delegate?.didGetRecipes(recipes: recipes, type: .recommended)
            }
            else {
                self.delegate?.didGetRecipes(recipes: recipes, type: .search)
            }
            
            
            
        }
    }
    
    private func processDownloadedRecipes(rawRecipeDicts:Array<[String:AnyObject]>) -> Array<Recipe> {
        
        
        let recipes:Array<Recipe> =  rawRecipeDicts.map{
            (rawRecipeDict:[String:AnyObject]) in
            let rawRecipe = rawRecipeDict["recipe"] as! [String:AnyObject];
            let recipe = Recipe()
            
            recipe.serving = rawRecipe["yield"] as! Int
            
            let healthLabels = rawRecipe["healthLabels"] as! Array<String>
            if healthLabels.count > 0 {
                
                recipe.healthLabels = healthLabels.reduce(""){text1, text2 in "\(text1), \(text2)"}
                recipe.healthLabels.remove(at: recipe.healthLabels.startIndex)
                recipe.healthLabels = recipe.healthLabels.replacingOccurrences(of: "-", with: " ")
            }
            else{
                recipe.healthLabels = "N/A"
            }
            
            let dietLabels = rawRecipe["dietLabels"] as! Array<String>
            if dietLabels.count > 0 {
                
                recipe.dietLabels = dietLabels.reduce(""){text1, text2 in "\(text1), \(text2)"}
                recipe.dietLabels.remove(at: recipe.dietLabels.startIndex)
                recipe.dietLabels = recipe.dietLabels.replacingOccurrences(of: "-", with: " ")
            }
            else {
                recipe.dietLabels = "N/A"
            }
            
            recipe.source = rawRecipe["source"] as! String
            recipe.imageUrlString = rawRecipe["image"] as! String
            recipe.title = rawRecipe["label"] as! String
            recipe.urlString = rawRecipe["url"] as! String
            
            
            recipe.calorie = Int(rawRecipe["calories"]!.floatValue)/recipe.serving
            let ingredients = rawRecipe["ingredientLines"] as! Array<String>
            for ingredient in ingredients {
                let item = Ingredient()
                item.ingredientDescription = ingredient
                recipe.ingredients.append(item)
            }
            return recipe
        }
        return recipes
    }
    
    
    
    
    private func recipeRecommededRequest(){  // request recommended recipes
        
        
        let startIndex = Int(arc4random_uniform(90))  //generate 10 recommended recipes
        recipeSearchRequest(keyword: "beef,chicken", from: startIndex, to: startIndex+10, search:false)
        
    }
    
    
    
    
    
    func removeRecipes(recipes:Array<Recipe>, type:RecipeType){
        
        
        let recipeStorage = RecipeStorage.sharedInstance.recipes
        for recipe in recipes{
            
            switch type {
                
            case .recommended:
                try! recipeStorage.write{
                    recipe.recommended = false
                }
                
                
            case .saved:
                try! recipeStorage.write{
                    recipe.saved = false
                    
                    
                }
               
                
            }
            try! recipeStorage.write {
                recipeStorage.add(recipe, update: true)
            }
            
        }
        
        
        
    }
    func addRecipes(recipes:Array<Recipe>, type:RecipeType){
        let recipeStorage = RecipeStorage.sharedInstance.recipes
        
        
        for recipe in recipes{
    
            switch type {
                
            case .recommended:
                
                try! recipeStorage.write{
                    recipe.recommended = true
                    recipeStorage.add(recipe, update: true)
                }
                if (recommendedRecipes.count >= 20){
                    
                    removeRecipes(recipes: [recommendedRecipes.first!], type: .recommended)
                    
                }
                
            case .saved:
                try! recipeStorage.write{
                    recipe.saved = true
                    recipeStorage.add(recipe, update: true)
                }
                
            }
            
            
        }
        
    }
    
    func removeIdleRecipes(){
        if(removeRecipes.count > 0){
            try! RecipeStorage.sharedInstance.recipes.write {
                RecipeStorage.sharedInstance.recipes.delete(removeRecipes)
            }
        }
        
    }
    
    
    
}

extension RecipeRequesterDelegate {
    
    func didfailToGetRecipe(error:RecipeRequestError){
        print(error)
        
    }
    
    
}




