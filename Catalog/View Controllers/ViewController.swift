//
//  ViewController.swift
//  Catalog
//
//  Created by Stepan Grachev on 15.01.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var products: [Product] = []
    var amounts: [Int: Int] = [:]
    var isLoadingProducts = false
    var currentProducts = 0
    var currentFilter = ""
    var selectedCell: DataCollectionViewCell?
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedCell != nil {
            amounts[selectedCell!.productId] = selectedCell?.currentAmount
            selectedCell!.updateAmount()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cartAmountChanged(_:_:)), name: Notification.Name(rawValue: "cartAmountChanged"), object: nil)
        self.getProducts()
    }
    
    @objc func cartAmountChanged(_ notification: Notification, _ productId: Int) {
        if let productId = notification.userInfo?["productId"] as? Int,
           let amount = notification.userInfo?["amount"] as? Int {
            amounts[productId] = amount
        }
    }
    
    
    func getProducts() {
        guard let url = URL(string: String("https://rstestapi.redsoftdigital.com/api/v1/products?filter[title]="+self.currentFilter+"&startFrom="+String(currentProducts)).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                  error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return }
                
            do {
                struct DataResponse: Codable {
                    var data: [Product]
                }
                let decoder = JSONDecoder()
                let response = try decoder.decode(DataResponse.self, from: dataResponse)
                
                var productsLoaded = false
                for product in response.data {
                    self.products.append(product)
                    if !self.amounts.keys.contains(product.id) {
                        self.amounts[product.id] = 0
                    }
                    productsLoaded = true
                }
                
                if self.currentProducts == 0 && response.data.count == 0 {
                    productsLoaded = true
                }
                
                if (productsLoaded) {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
                self.isLoadingProducts = false
                
            } catch let parsingError {
                print("Error", parsingError)
                
            }
            
        }
        task.resume()
    }
    
    func loadMoreProducts() {
        self.currentProducts += 10
        getProducts()
    }
}

var timer: Timer?

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch(sender:)), userInfo: ["searchText": searchText], repeats: false)
    }
    @objc func performSearch(sender: Timer) {
        self.currentFilter = ((sender.userInfo as? [String : String])?["searchText"])!
        self.currentProducts = 0

        products.removeAll()

        getProducts()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UICollectionViewDataSource,
                          UICollectionViewDelegate,
                          UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DataCollectionViewCell
        
        cell?.layer.cornerRadius = 10.0
        cell?.clipsToBounds = true
        cell!.layer.borderWidth = 0.5
        cell!.layer.borderColor = UIColor.lightGray.cgColor
        cell?.addToCart.layer.cornerRadius = 5
        
        cell?.less.roundCorners([.topLeft, .bottomLeft], radius: 5)
        cell?.more.roundCorners([.topRight, .bottomRight], radius: 5)
        
        if (indexPath.row < products.count) {
            let imageTapGesture = ProductGestureRecognizer(target: self, action: #selector(self.toDetailedViewController(gesture:)))
            let titleTapGesture = ProductGestureRecognizer(target: self, action: #selector(self.toDetailedViewController(gesture:)))
            imageTapGesture.productId = products[indexPath.row].id
            titleTapGesture.productId = products[indexPath.row].id
            imageTapGesture.productTitle = products[indexPath.row].title
            titleTapGesture.productTitle = products[indexPath.row].title
            imageTapGesture.cell = cell
            titleTapGesture.cell = cell
            
            cell?.image.addGestureRecognizer(imageTapGesture)
            cell?.title.addGestureRecognizer(titleTapGesture)
            
            cell?.image.loadFromUrl(urlString: products[indexPath.row].image_url)
            cell?.category.text = products[indexPath.row].categories.count > 0 ?
                products[indexPath.row].categories[0].title : ""
            cell?.title.text = products[indexPath.row].title
            cell?.producer.text = products[indexPath.row].producer
            cell?.price.text = String(format: "%.2f", products[indexPath.row].price)+" ₽"
            cell?.amount = products[indexPath.row].amount
            cell?.productId = products[indexPath.row].id
            
            cell?.currentAmount = amounts[products[indexPath.row].id]!
            cell?.updateAmount()
        }
        
        return cell!
    }
    
    @objc func toDetailedViewController(gesture: ProductGestureRecognizer) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailedViewController = storyboard.instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        detailedViewController.productId = gesture.productId!
        detailedViewController.productTitle = gesture.productTitle!
        detailedViewController.currentAmount = gesture.cell!.currentAmount
        detailedViewController.cell = gesture.cell!
        selectedCell = gesture.cell!
        
        navigationController?.pushViewController(detailedViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            let width  = view.frame.width-32
            return CGSize(width: width, height: width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height)
                && !isLoadingProducts) {
            isLoadingProducts = true
            loadMoreProducts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    class ProductGestureRecognizer: UITapGestureRecognizer {
        var productId: Int?
        var productTitle: String?
        var cell: DataCollectionViewCell?
    }
}

