//
//  ViewController.swift
//  PizzaApp
//
//  Created by mac on 5/8/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import Firebase

class TopPizzasViewController: UIViewController {
    
    @IBOutlet weak var pizzaTableView: UITableView!
    
    @IBOutlet weak var segmentControl_sort: UISegmentedControl!
    
    var filteredPizzaOrders = [(Pizza, Int)]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var pizzas: [(Pizza, Int)] = []
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pizza Orders"
        searchController.isActive = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //fetch pizzas
        fetchPizzas(count: Preferences.pizzaCount)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    //MARK: Fetch Pizzas based on selected index of segment control
    func fetchPizzas(count: Int){
        
        //check index of segment control
        if segmentControl_sort.selectedSegmentIndex == 0
        {
            getPizzas(count: count, segmentControlIndex: 0)
        }
        else if segmentControl_sort.selectedSegmentIndex == 1
        {
            getPizzas(count: count, segmentControlIndex: 1)
        }
        else
        {
            getPizzas(count: count, segmentControlIndex: 2)
        }
        
    }
    
    // MARK: Get Pizzas
    func getPizzas(count: Int, segmentControlIndex: Int)
    {
        PizzaService.getPizzas(limit: count, sort: segmentControlIndex){ [unowned self] pizzas in
            self.pizzas = pizzas
            DispatchQueue.main.async {
                self.pizzaTableView.reloadData()
            }
        }
    }
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SettingsViewController else {
            return
        }
        
        vc.delegate = self
    }
    
    // MARK: Segment control changes index
    @IBAction func segmentControlIndexChanged(_ sender: Any) {
        self.fetchPizzas(count: Preferences.pizzaCount)
    }
    
    // MARK: Check if search bar is empty
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: Filter search results
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredPizzaOrders = pizzas.filter({( pizza : Pizza, int: Int) -> Bool in
            
            return pizza.toppings.joined(separator: ", ").lowercased().contains(searchText.lowercased())
            
        })
        
        pizzaTableView.reloadData()
    }
    
    // MARK: Check if search bar is active
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension TopPizzasViewController: SettingsDelegate {
    
    func updatedPizzaCount(to count: Int) {
        fetchPizzas(count: count)
    }
}

extension TopPizzasViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPizzaOrders.count
        }
        return pizzas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PizzaCell", for: indexPath)
        
        let pizza: Pizza
        if isFiltering() {
            pizza = filteredPizzaOrders[indexPath.row].0
        } else {
            pizza = pizzas[indexPath.row].0
        }
        
        //let pizza = pizzas[indexPath.row].0
        cell.textLabel?.text = pizza.toppings.joined(separator: ", ")
        
        let number = "\(pizzas[indexPath.row].1)"
        cell.detailTextLabel?.text = "Number of orders placed: \(number)"
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
   
}

extension TopPizzasViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)

    }
    
}
