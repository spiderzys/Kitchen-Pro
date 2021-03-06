//
//  ViewController.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-21.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let recipeRequester = RecipeRequester.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    
        
        setBackground()

        // Do any additional setup after loading the view.
    }
    
    func setBackground(){
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = UIImage(named: "launch")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.12
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
        
    }
    
    func showAlert(message:String){
        let alertController = UIAlertController(title: nil, message:message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
             alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion:nil)
        
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
