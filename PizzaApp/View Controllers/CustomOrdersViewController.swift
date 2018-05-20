//
//  CustomOrdersViewController.swift
//  PizzaApp
//
//  Created by Admin on 5/10/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit

class CustomOrdersViewController: UIViewController{
    
    @IBOutlet weak var tbl_customOrders: UITableView!
    var arr_customPizzas = [CustomPizzaOrder]()
    var row: Int!
    let activityIndicator = ActivityIndicatorService.shared.indicator
    
    //MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //setup activity indicator
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        arr_customPizzas.removeAll()
        
        DispatchQueue.global().async {
            self.fetchData() //fetch all orders
        }
        
        //add observer to recieve notification
        NotificationCenter.default.addObserver(self, selector: #selector(finishPassing), name: NSNotification.Name(rawValue: "deleted"), object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Fetch all orders and favorite orders
    func fetchData(){
        
        PizzaService.getAllOrders { (allOrders) in
            self.arr_customPizzas = allOrders
            
            DispatchQueue.main.async {
                //check if pizza orders are empty and load data accordingly
                if self.arr_customPizzas.count > 0
                {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    
                    self.tbl_customOrders.reloadData()
                    let ip = IndexPath(row: self.arr_customPizzas.count-1, section: 0)
                    self.tbl_customOrders.scrollToRow(at: ip, at: .top, animated: true)
                }
            }
        }
    }
    
    //MARK: Delete row and update table when notification is posted
    @objc func finishPassing() {
        let indexPath = IndexPath(row: row, section: 0)
        self.arr_customPizzas.remove(at: indexPath.row)
        
        DispatchQueue.main.async {
            self.tbl_customOrders.deleteRows(at: [indexPath], with: .top)
        }
      
    }
    
    //MARK: Toggle checkmark on cell
    func toggleCellCheckbox(_ cell: UITableViewCell, isfavorite: Bool) {
        if !isfavorite {
            cell.accessoryType = .none
            
        } else {
            cell.accessoryType = .checkmark
        }
        
    }
    
}

extension CustomOrdersViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_customPizzas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "customPizzaCell")
        let topping = arr_customPizzas[indexPath.row]
        cell.textLabel?.text = topping.toppings.joined(separator: ", ")
        cell.textLabel?.numberOfLines = 0
        
        //check which order is favorite
        toggleCellCheckbox(cell, isfavorite: topping.favorite)
        
        return cell
        
    }
    
}

extension CustomOrdersViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
            let pizzaOrder = arr_customPizzas[indexPath.row]
        
            let toggledCompletion = !pizzaOrder.favorite
            toggleCellCheckbox(cell!, isfavorite: toggledCompletion)
            
            PizzaService.updatePizzaOrder(favorite: toggledCompletion, pizzaOrder: pizzaOrder)
            tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete
        {
            row = indexPath.row
            let pizzaOrder = arr_customPizzas[indexPath.row]
            PizzaService.deletePizzaOrder(index:row, pizzaOrder: pizzaOrder)
        
        }
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}


