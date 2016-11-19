//
//  RecipeRequester.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import Alamofire

protocol RecipeRequesterDelegate:class {
    
    func didGetQuesRecipes(recipes:Array<Recipe>)
    func didGetRecommendedRecipes(recipes:Array<Recipe>)
    func didGetSavedRecipes(recipes:Array<Recipe>)
    
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

class RecipeRequester {
    
    static let sharedInstance = RecipeRequester()
    let apikey = "app_id=ac0ab8e9&app_key=fb39a454934a7a5a74b8adcb3a8b3985"
    let searchBaseString =  "https://api.edamam.com/search?"
    weak var delegate:RecipeRequesterDelegate?
   
    //  var health: [String:Bool]?
    // var diet = ""
    // var to = ""
    
    
    
    func recipeRequest(type:RecipeRequestType, searchKey:String?){
        guard delegate != nil else {
            
            print("no delegate set yet")
            return
        }
        
        switch type {
        case .saved:
            savedRecipeRequest()
        case .search:
            recipeSearchRequest(keyword: searchKey)
        default:
            <#code#>
        }
    }
    
    
    
    private func recipeSearchRequest(keyword:String? , from:Int , to:Int){
        
        if keyword == nil || keyword?.characters.count == 0  {
            
            delegate?.didfailToGetRecipe(error: RecipeRequestError.key_null)
            return
        }
    
        let requestString = String(format: "%@%@&from=%d&to=%d&q=%@", searchBaseString,apikey,from,to,modifiedKeyword(keyword: keyword!))
        
        request(requestString)
        
    }
    
    
    
    private func modifiedKeyword(keyword:String) -> String {
        var key = keyword.replacingOccurrences(of: ",", with: "+");
        key = key.replacingOccurrences(of: " ", with: "-")
    }
    
    
    private func recipeRequest(url:URLConvertible){
        Alamofire.request(url).responseJSON { response in
            
            guard let JSON = response.result.value as? [String:AnyObject]  else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.response_error)
                return
            }
            
            guard let recipes = JSON["hits"] as? Array<[String:AnyObject]> else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.hits_error)
                return
            }
            
            guard recipes.count > 0 else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.recipes_null)
                return
            }
        }
    }
    
    
   private func recipeSearchRequest(keyword:String!){
        
        recipeSearchRequest(keyword: keyword, from: 0, to: 100)
        
    }
    
    
   private func recipeRecommededRequest(){
    
        let recommendedRecipes = RecipeStorage.sharedInstance.recipeStorage.objects(Recipe.self).filter("recommended == true")
    
        if recommendedRecipes.count > 0 {
            delegate?.didGetRecommendedRecipes(recipes: Array(recommendedRecipes))
            return 
        }
        recipeSearchRequest(keyword: "beef,chicken", from: 0, to: 20)
              
    }
    
   private func savedRecipeRequest(){
        guard delegate != nil else {
            
            print("no delegate set yet")
            return
        }
        
        

    }
    
    
    
}

extension RecipeRequesterDelegate {
    func didfailToGetRecipe(error:RecipeRequestError){
        print(error)
        
    }
}




