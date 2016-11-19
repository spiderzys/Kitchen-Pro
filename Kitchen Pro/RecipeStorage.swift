//
//  RecipeStorage.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016_11_15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import RealmSwift



class RecipeStorage {
    static let sharedInstance = RecipeStorage()
    let recipeStorage = try! Realm()
    
    func setRecommendedRecipes() -> Results<Recipe>{
        let recommendedRecipes = RecipeStorage.sharedInstance.recipeStorage.objects(Recipe.self).filter("recommended == true")
        
        if recommendedRecipes.count == 0 {
            // generate static recommended recipes
        }
        
        return recommendedRecipes
        

       
    }
    
    
    func originalRecipesGenerated(){
        
    }
    
}

class ingredient: Object {
    
    dynamic var ingredientDescription = ""
    dynamic var prepared = false
    
}


class Recipe:Object{
    
    
    dynamic var imageData = NSDate()
    dynamic var imageUrlString = ""
    
    dynamic var iconData = NSData()
    dynamic var iconUrlString = ""
    
    var ingredients = List<ingredient>()
    dynamic var note = ""
    dynamic var calorie: Float = 0;
    dynamic var saved = false
    dynamic var recommended = false
    dynamic var healthLabels = ""
    dynamic var dietLabels = ""
    
    


    
}


