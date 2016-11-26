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
    let recipes = try! Realm()
    
}

class Ingredient: Object {
    
    dynamic var ingredientDescription = ""
    dynamic var prepared = false
    
}

class Recipe:Object{
    
    
    dynamic var imageUrlString = ""
    var ingredients = List<Ingredient>()
    dynamic var serving = 0
    dynamic var source = ""
    dynamic var calorie:Int = 0
    dynamic var saved = false
    dynamic var recommended = false
    dynamic var healthLabels = ""
    dynamic var dietLabels = ""
    dynamic var title = ""
    dynamic var urlString = ""

    override static func primaryKey() -> String? {
        return "urlString"
    }
    
}




