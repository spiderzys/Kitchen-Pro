//
//  ImageLoader.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-17.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

enum ImageLoaderError: String{
    case no_data = "No data"
    case error_image_data = "Fail to init image from data"
}

class ImageLoader {
    
    static let sharedInstance = ImageLoader()
    
    let imageCache = AutoPurgingImageCache()
    
    
    func loadImage(url:URL, completion: @escaping (UIImage) -> Void) {
        
        
        guard let image = imageCache.image(withIdentifier: url.absoluteString) else{
            Alamofire.request(url).responseImage { response in
                
                
                guard let image = response.result.value  else{
          
                    return
                }
                self.imageCache.add(image, withIdentifier: url.absoluteString)
                completion(image)
                
            }
            return
        }
      
        completion(image)

                
    }
    
}

