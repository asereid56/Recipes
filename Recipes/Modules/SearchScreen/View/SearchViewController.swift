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
    
    
    private var subCategories: [String] = []
    private var selectedCategorySubject = CurrentValueSubject<String?, Never>(nil)
    private var subCategorySubject = PassthroughSubject<Void, Never>()
    private var searchTextSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var selectedSubCategories: [String] = []
    private var latestQuery: String = ""
    private var currentMainCategory: String = ""
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
                
                let lowercasedCategory = selectedCategory.lowercased()
                
                switch lowercasedCategory {
                case "all":
                    self.selectedSubCategories = []
                    if !self.latestQuery.isEmpty {
                        self.viewModel?.fetchData(endpoint: "&q=\(self.latestQuery)", url: Constant.baseURL)
                    }
                    self.animateCategoryView(hideSubCategoryView: true, tableViewConstant: 4)
                    self.mainCategoryCollectionView.reloadData()
                    
                case "health":
                    self.subCategories = Constant.healthSubCategories
                    
                case "diet":
                    self.subCategories = Constant.dietaryOptions
                    
                case "mealtype":
                    self.subCategories = Constant.mealTypes
                    
                case "cuisinetype":
                    self.subCategories = Constant.cuisines
                    
                default:
                    break
                }
                
                if lowercasedCategory != "all" {
                    self.animateCategoryView(hideSubCategoryView: false, tableViewConstant: self.subCategoryViewHeight)
                }
                
                self.subCategoryCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        subCategorySubject
            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] in
                guard let self = self else { return }
                
                if checkInternetAndShowToast(vc: self) {
                    if !self.latestQuery.isEmpty {
                        let endPoint = (self.viewModel?.makeAllURL(filters: selectedSubCategories) ?? "") + "&q=\(self.latestQuery)"
                        self.viewModel?.fetchData(endpoint: endPoint, url: Constant.baseURL)
                    }
                }
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
                
                self.latestQuery = query
                if checkInternetAndShowToast(vc: self) {
                    self.viewModel?.fetchData(endpoint: (self.viewModel?.makeAllURL(filters: selectedSubCategories) ?? "") + "&q=\(query)", url: Constant.baseURL)
                }
            }
            .store(in: &cancellables)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            latestQuery = ""
            viewModel?.recipes = []
            return
        }
        searchTextSubject.send(searchText)
    }
    
    private func animateCategoryView(hideSubCategoryView: Bool, tableViewConstant: CGFloat) {
        UIView.animate(withDuration: 0.7) {
            self.subCategoryCollectionView.isHidden = hideSubCategoryView
            self.upperConstraintForTableView.constant = tableViewConstant
            self.view.layoutIfNeeded()
        }
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = viewModel?.recipes.count ?? 0
        if result == 0 {
            tableView.isHidden = true
            emptyPhoto.isHidden = false
        }else{
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
        if indexPath.item == (viewModel?.recipes.count ?? 0) - 1{
            viewModel?.loadMoreData()
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
            let category = Constant.mainCategories[indexPath.row].capitalized
            cell.configure(with: category, isSelected: selectedSubCategories.filter({ $0.lowercased().contains(category.lowercased())}).count > 0)
            
        }else if collectionView == subCategoryCollectionView {
            let subCategory = subCategories[indexPath.row].capitalized
            cell.configure(with: subCategory, isSelected: selectedSubCategories.filter({ $0.lowercased().contains(subCategory.lowercased())}).count > 0)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedCategory = ""
        
        if collectionView == mainCategoryCollectionView {
            selectedCategory = Constant.mainCategories[indexPath.row]
            self.currentMainCategory = selectedCategory
            selectedCategorySubject.send(selectedCategory)
            
        }else if collectionView == subCategoryCollectionView {
            
            selectedCategory = subCategories[indexPath.row]
            
            if selectedSubCategories.filter({ $0.lowercased().contains(selectedCategory.lowercased())}).count > 0 {
                selectedSubCategories.removeAll {$0.contains(selectedCategory)}
            } else {
                selectedSubCategories.append("\(currentMainCategory)=\(selectedCategory)")
            }
            
            subCategorySubject.send(())
        }
        
        mainCategoryCollectionView.reloadData()
        subCategoryCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.layer.borderColor = (self.selectedSubCategories.filter({ $0.lowercased().contains(selectedCategory.lowercased())}).count > 0 || Constant.mainCategories.contains(selectedCategory)) ? UIColor.cyan.cgColor : UIColor.clear.cgColor
                cell.layer.borderWidth = (self.selectedSubCategories.filter({ $0.lowercased().contains(selectedCategory.lowercased())}).count > 0 || Constant.mainCategories.contains(selectedCategory)) ? 3 : 0
            }
        }
        
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
