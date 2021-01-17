//
//  Product.swift
//  Catalog
//
//  Created by Stepan Grachev on 17.01.2021.
//

import UIKit

struct Product: Codable {
    var id: Int
    var title: String
    var short_description: String
    var image_url: String
    var amount: Int
    var price: Double
    var producer: String
    var categories: [Category]
}
