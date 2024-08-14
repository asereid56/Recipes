//
//  ViewController.swift
//  Recipes
//
//  Created by Aser Eid on 13/08/2024.
//

import UIKit
import Combine
import Kingfisher

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainCategoryCollectionView: UICollectionView!
    @IBOutlet weak var subCategoryCollectionView: UICollectionView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var upperConstraintForTableView: NSLayoutConstraint!
    @IBOutlet weak var emptyPhoto: UIImageView!
    
    
    var subCategories: [String] = []
    private var selectedCategorySubject = CurrentValueSubject<String?, Never>(nil)
    private var searchTextSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var subCategoryViewHeight: CGFloat = 0
    private var viewModel : SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.upperConstraintForTableView.constant = 4
        viewModel = SearchViewModel(networkService: NetworkService())
        
        let collectionNib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        mainCategoryCollectionView.register(collectionNib, forCellWithReuseIdentifier: "categoryCell")
        subCategoryCollectionView.register(collectionNib, forCellWithReuseIdentifier: "categoryCell")
        let tableNib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
        myTableView.register(tableNib, forCellReuseIdentifier: "recipeCell")
        
        setUpBinding()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subCategoryViewHeight = subCategoryCollectionView.frame.height + 12
    }
    
    private func setUpBinding(){
        selectedCategorySubject
            .compactMap { $0 }
            .sink { [weak self] selectedCategory in
                guard let self = self else { return }
                if selectedCategory == "All" {
                    UIView.animate(withDuration: 2) {
                        self.subCategoryCollectionView.isHidden = true
                        self.upperConstraintForTableView.constant = 4
                    }
                    
                }else if selectedCategory == "Health" {
                    self.subCategories = Constant.healthSubCategories
                    UIView.animate(withDuration: 2) {
                        self.subCategoryCollectionView.isHidden = false
                        self.upperConstraintForTableView.constant = self.subCategoryViewHeight
                    }
                }
                self.subCategoryCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel?.$recipes
            .receive(on: DispatchQueue.main)
            .sink{ [weak self ] _ in
                self?.myTableView.reloadData()
            }.store(in: &cancellables)
        
        searchTextSubject
            .throttle(for: .seconds(3), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] query in
                guard let self = self else { return }
                
                if checkInternetAndShowToast(vc: self) {
                    self.viewModel?.fetchData(endpoint: (self.viewModel?.makeAllURL(fields: ["label", "source", "image"], healths: []) ?? "") + "&q=\(query)", url: Constant.baseURL)
                }
            }
            .store(in: &cancellables)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchText)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = viewModel?.recipes.count ?? 0
        if result == 0 {
            subCategoryCollectionView.isHidden = true
            mainCategoryCollectionView.isHidden = true
            tableView.isHidden = true
            emptyPhoto.isHidden = false
        }else{
            subCategoryCollectionView.isHidden = false
            mainCategoryCollectionView.isHidden = false
            tableView.isHidden = false
            emptyPhoto.isHidden = true
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        
        if let recipe = viewModel?.recipes[indexPath.row].recipe {
            cell.configure(with: recipe)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if checkInternetAndShowToast(vc: self){
            let detailsVM = DetailsRecipeViewModel(network: NetworkService())
            detailsVM.url = viewModel?.recipes[indexPath.item].links?.linksSelf.href ?? ""
            
            if let detailsVC = storyboard?.instantiateViewController(identifier: "Details") as? RecipeDetailsViewController {
                
                detailsVC.viewModel = detailsVM
                
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 141.33
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight {
            if checkInternetAndShowToast(vc: self){
                viewModel?.loadMoreData()
            }
        }
    }
}
extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCategoryCollectionView {
            return Constant.mainCategories.count
        }else if collectionView == subCategoryCollectionView {
            return subCategories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        if collectionView == mainCategoryCollectionView {
            let category = Constant.mainCategories[indexPath.row]
            cell.configure(with: category)
            
        }else if collectionView == subCategoryCollectionView {
            let subCategory = subCategories[indexPath.row]
            cell.configure(with: subCategory)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mainCategoryCollectionView {
            let selectedCategory = Constant.mainCategories[indexPath.row]
            selectedCategorySubject.send(selectedCategory)
        }
    }
    
}
