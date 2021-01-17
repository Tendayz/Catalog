//
//  Category.swift
//  Catalog
//
//  Created by Stepan Grachev on 17.01.2021.
//

import UIKit

struct Category: Codable {
    var id: Int
    var title: String
    var parent_id: Int?
}
