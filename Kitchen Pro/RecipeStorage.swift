//
//  RecipeStorage.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016_11_15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeStorage: NSObject {

    let recipeStorage = try! Realm()
    
}


class ingredient: Object {
    
    dynamic var ingredientDescription:String?
    dynamic var prepared = false
    
}




class Recipe:Object{
    
    dynamic var count = 0
    dynamic var imageData = NSDate()
    dynamic var iconData = NSData()
    var ingredients = List<ingredient>()
    dynamic var note = ""
    dynamic var calory: Float = 0;
    dynamic var lastRecommeded = false
    dynamic var saved = true
    dynamic var recommeded = true
    dynamic var healthLabels = ""
    dynamic var dietLabels = ""


    
}


