//
//  RecipeWebViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-19.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class RecipeWebViewController: UIViewController {

    var recipeUrl:URL?
    var recipeTitle:String?
    @IBOutlet weak var recipeWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if recipeUrl != nil {
            let request = URLRequest(url: recipeUrl!)
            recipeWebView.loadRequest(request)
        }
        
        navigationItem.title = recipeTitle
        

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
