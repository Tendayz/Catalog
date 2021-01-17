//
//  UIImageView+ImageFromUrl.swift
//  Catalog
//
//  Created by Stepan Grachev on 17.01.2021.
//

import UIKit

extension UIImageView {
    
    public func loadFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
            let session = URLSession.shared
            session.dataTask(with: request as URLRequest) {data, response, err in
                if let imageData = data {
                    DispatchQueue.main.async {
                        if UIImage(data: imageData) != nil {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.image = UIImage(named: "empty")
                        }
                    }
                }
            }.resume()
        }
    }
    
}
