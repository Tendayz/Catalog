//
//  DataCollectionViewCell.swift
//  Catalog
//
//  Created by Stepan Grachev on 15.01.2021.
//

import UIKit

class DataCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var producer: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var addToCart: UIButton!
    @IBOutlet weak var less: UIButton!
    @IBOutlet weak var more: UIButton!
    @IBOutlet weak var amountText: UILabel!
    
    var productId = 0
    var amount = 0
    var currentAmount = 0
    var userInfo:[String: Int] = ["productId": 0, "amount": 0]
    
    @IBAction func addToCart(_ sender: UIButton) {
        if amount > 0 {
            currentAmount = 1
            addToCart.isHidden = true
            less.isHidden = false
            more.isHidden = false
            amountText.isHidden = false
            amountText.text = String(currentAmount)+" шт"
        }
        userInfo["productId"] = productId
        userInfo["amount"] = currentAmount
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cartAmountChanged"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func less(_ sender: UIButton) {
        currentAmount -= 1
        if currentAmount == 0 {
            addToCart.isHidden = false
            less.isHidden = true
            more.isHidden = true
            amountText.isHidden = true
        } else {
            amountText.text = String(currentAmount)+" шт"
        }
        userInfo["productId"] = productId
        userInfo["amount"] = currentAmount
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cartAmountChanged"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func more(_ sender: Any) {
        if currentAmount < amount {
            currentAmount += 1
            amountText.text = String(currentAmount)+" шт"
        }
        userInfo["productId"] = productId
        userInfo["amount"] = currentAmount
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cartAmountChanged"), object: nil, userInfo: userInfo)
    }
    
    func updateAmount() {
        if currentAmount > 0 {
            addToCart.isHidden = true
            less.isHidden = false
            more.isHidden = false
            amountText.isHidden = false
            amountText.text = String(currentAmount)+" шт"
        } else {
            addToCart.isHidden = false
            less.isHidden = true
            more.isHidden = true
            amountText.isHidden = true
        }
    }
}
