//
//  Kitchen_ProTests.swift
//  Kitchen ProTests
//
//  Created by YANGSHENG ZOU on 2016-11-24.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import XCTest
import RealmSwift


class Recipe:Object{
    
    
    dynamic var calorie:Int = 0
    dynamic var saved = false
    dynamic var urlString = ""
    
    override static func primaryKey() -> String? {
        return "urlString"
    }
    
}



class Kitchen_ProTests: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    /*
    func testRealm() {
        let config = Realm.Configuration(
            // Get the URL to the bundled file
            fileURL: Bundle.main.url(forResource: "MyBundledData", withExtension: "realm"),
            // Open the file in read-only mode as application bundles are not writeable
            readOnly: false)
        let realm = try! Realm(configuration: config)
        realm.deleteAll()
        let recipes = realm.objects(Recipe.self)
        XCTAssertEqual(recipes.count, 0)
        var recipeArray: Array<Recipe> = Array()
        
        for i in 0...10 {
            let recipe = Recipe()
                recipe.urlString = String(i)
                recipe.calorie = i;
                recipeArray.append(recipe)
            
        }
        XCTAssertEqual(recipes.count, 0)
        
        try! realm.write {
            recipeArray[0].calorie = 99
        }
         XCTAssertEqual(recipes.count, 0)
        
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
   */
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
