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
    
    func didGetRecipe(recipe:Recipe)
    func didfailToGetRecipe(error:RecipeRequestError)
    
}

enum RecipeRequestError:String {
    case response_error = "no response"
    case hits_error = "invaild return"
    case recipes_error = "no recipes found"
}


class RecipeRequester {
    
    static let sharedInstance = RecipeRequester()
    let apikey = "app_id=ac0ab8e9&app_key=fb39a454934a7a5a74b8adcb3a8b3985"
    let searchBaseString =  "https://api.edamam.com/search?"
    weak var delegate:RecipeRequesterDelegate?
   
    //  var health: [String:Bool]?
    // var diet = ""
    // var to = ""
    
    
   
    
    func recipeSearchRequest(keyword:String! , from:Int , to:Int){
        
        guard delegate != nil else {
            print("no delegate")
            return
        }
        
        let requestString = String(format: "%@%@&from=%d&to=%d&q=%@", searchBaseString,apikey,from,to,keyword)
        
        Alamofire.request(requestString).responseJSON { response in
            
            guard let JSON = response.result.value as? [String:AnyObject]  else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.response_error)
                return
            }
            
            guard let recipes = JSON["hits"] else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.response_error)
                return
            }
            
            guard recipes.count > 0 else{
                self.delegate?.didfailToGetRecipe(error:RecipeRequestError.response_error)
                return
            }
            
            
        }
        
    }
    
    func recipeSearchRequest(keyword:String!){
        
        recipeSearchRequest(keyword: keyword, from: 0, to: 100)
        
    }
    
    
    
    func recipeRecommededRequest(){
        
              
    }
    
    
}

extension RecipeRequesterDelegate {
    func didfailToGetRecipe(error:RecipeRequestError){
        print(error)
        
    }
}




