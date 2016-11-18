//
//  ImageLoader.swift
//  Kitchen Pro
//
//  Created by YANGSHENG ZOU on 2016-11-17.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import Alamofire

protocol ImageLoaderDelegate {
    func didFinishLoading(image:UIImage);
    func didLoadingFailed(error:Error);
}

class ImageLoader: NSObject {
    
    
    
    func loadImage(url:URL) {
        Alamofire.download(url).responseData { response in
            if let data = response.result.value {
                let image = UIImage(data: data)
            }
        }
        
        
    }
    
}

extension ImageLoaderDelegate {
    func didLoadingFailed(error:Error){
        
    }
}
