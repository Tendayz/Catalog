//
//  DetailedViewController.swift
//  Catalog
//
//  Created by Stepan Grachev on 17.01.2021.
//

import UIKit

class DetailedViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var category1: UILabel!
    @IBOutlet weak var category2: UILabel!
    @IBOutlet weak var category3: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var addToCartBtn: ButtonWithImage!
    @IBOutlet weak var lessBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    
    var categories = [UILabel]()
    var cell: DataCollectionViewCell?
    
    var productId = 0
    var productTitle = ""
    var currentAmount = 0
    var amount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = [category1, category2, category3]
        let backButton = UIBarButtonItem()
        backButton.title = productTitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        lessBtn.roundCorners([.topLeft, .bottomLeft], radius: 5)
        moreBtn.roundCorners([.topRight, .bottomRight], radius: 5)
        
        if currentAmount > 0 {
            amountLabel.text = String(currentAmount)+" шт"
            addToCartBtn.isHidden = true
            lessBtn.isHidden = false
            moreBtn.isHidden = false
            amountLabel.isHidden = false
        }
        
        getProduct()
    }
    
    func getProduct() {
        setLoading(enabled: true)
        guard let url = URL(string: "https://rstestapi.redsoftdigital.com/api/v1/products/"+String(productId))
        else {return}
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                      error == nil else {
                      print(error?.localizedDescription ?? "Response Error")
                      return }
                
                do {
                    struct DataResponse: Codable {
                        var data: Product
                    }
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(DataResponse.self, from: dataResponse)
                    
                    self.amount = response.data.amount
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = response.data.title
                        self.producerLabel.text = response.data.producer
                        self.descriptionLabel.text = response.data.short_description
                        self.priceLabel.text = String(format: "%.2f", response.data.price)+" ₽"
                        self.image.loadFromUrl(urlString: response.data.image_url)
                        
                        for i in 0..<response.data.categories.count {
                            if i < self.categories.count {
                                self.categories[i].text = response.data.categories[i].title
                                self.categories[i].isHidden = false
                            }
                        }
                        
                        self.setLoading(enabled: false)
                    }
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
            task.resume()
    }
    
    func setLoading(enabled: Bool) {
        if enabled {
            titleLabel.isHidden = true
            producerLabel.isHidden = true
            descriptionLabel.isHidden = true
            priceLabel.isHidden = true
        } else {
            titleLabel.isHidden = false
            producerLabel.isHidden = false
            descriptionLabel.isHidden = false
            priceLabel.isHidden = false
        }
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        if amount > 0 {
            currentAmount = 1
            addToCartBtn.isHidden = true
            lessBtn.isHidden = false
            moreBtn.isHidden = false
            amountLabel.isHidden = false
        }
        cell!.currentAmount = currentAmount
    }
    
    @IBAction func less(_ sender: UIButton) {
        currentAmount -= 1
        if (currentAmount == 0) {
            addToCartBtn.isHidden = false
            lessBtn.isHidden = true
            moreBtn.isHidden = true
            amountLabel.isHidden = true
        } else {
            amountLabel.text = String(currentAmount)+" шт"
        }
        cell!.currentAmount = currentAmount
    }

    @IBAction func more(_ sender: Any) {
        if currentAmount < amount {
            currentAmount += 1
            amountLabel.text = String(currentAmount)+" шт"
        }
        cell!.currentAmount = currentAmount
    }

}
