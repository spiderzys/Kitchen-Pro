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

protocol ImageLoaderDelegate: class {
    func didFinishLoading(image:UIImage);
    func didLoadingFailed(error:ImageLoaderError);
}


enum ImageLoaderError: String{
    case no_data = "No data"
    case error_image_data = "Fail to init image from data"
}

class ImageLoader {
    
    static let sharedInstance = ImageLoader()
    
    weak var delegate:ImageLoaderDelegate?
    
    let imageCache = AutoPurgingImageCache()
    
    
    func loadImage(url:URL) {
        guard delegate != nil
            else{
                print("nil delegate exception")
                return
        }
        
        guard let image = imageCache.image(withIdentifier: url.absoluteString) else{
            Alamofire.request("https://httpbin.org/image/png").responseImage { response in
                
                
                guard let image = response.result.value  else{
                    self.delegate?.didLoadingFailed(error: ImageLoaderError.error_image_data)
                    return
                }
                self.imageCache.add(image, withIdentifier: url.absoluteString)
                self.delegate?.didFinishLoading(image: image)
                
            }
            return
        }
        self.delegate?.didFinishLoading(image: image)
        
        /*  use AlamofireImage instead
        Alamofire.download(url).responseData { response in
            guard let data = response.result.value
                else{
                    self.delegate?.didLoadingFailed(error: ImageLoaderError.no_data)
                    return
            }
            
            guard let image = UIImage(data: data)
                else{
                    self.delegate?.didLoadingFailed(error: ImageLoaderError.error_image_data)
                    return
            }
            
            self.delegate?.didFinishLoading(image: image)
        }
        */
        
    }
    
}

extension ImageLoaderDelegate {
    func didLoadingFailed(error:ImageLoaderError){
        
    }
}
