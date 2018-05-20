//
//  ToppingsViewController.swift
//  PizzaApp
//
//  Created by mac on 5/10/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit

class ToppingsViewController: UIViewController {
    
    @IBOutlet weak var toppingsTableView: UITableView!
    @IBOutlet weak var toppingsPickerView: UIPickerView!
    
    let cellIdentifier = "ToppingCell"
    
    var toppings = [String]()
    var customTopping: String?
    var enableAction: UIAlertAction!
    var selectedToppings = [String]()
    
    let activityIndicator = ActivityIndicatorService.shared.indicator
    
    //MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //setup activity indicator
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        //add abserver to recieve notification
        NotificationCenter.default.addObserver(self, selector: #selector(finishPassing), name: NSNotification.Name(rawValue: "saved"), object: nil)
        
        //get all custom toppings and load in pickerview
        CustomToppingsService.getAllToppings { (customToppings) in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            
            self.toppings = customToppings
            self.toppingsPickerView.reloadAllComponents()
            self.selectedToppings = []
            self.toppingsTableView.reloadData()
            
        }
    }
    
    //MARK: Update picker view
    @IBAction func toppingAdded(_ sender: Any) {
        guard !toppings.isEmpty else { return }
        
        let row = toppingsPickerView.selectedRow(inComponent: 0)
        
        let selectedTopping = toppings[row]
        
        //print("Selected \(selectedTopping)")
        toppings.remove(at: row)
        toppings = toppings.sorted()
        toppingsPickerView.reloadAllComponents()
     
        addTopping(selectedTopping)
    }
    
    //MARK: Add topping to selected toppings
    func addTopping(_ topping: String){
        
        // add to the array of selected toppings
        selectedToppings.append(topping)
        
        // get the index path of the new row
        let ip = IndexPath(row: selectedToppings.count-1, section: 0)
        
        // update table view
        toppingsTableView.insertRows(at: [ip], with: .automatic)
    }
    
    //MARK: Order Pizza
    @IBAction func pizzaOrdered(_ sender: Any) {
        
        PizzaService.saveOrder(toppings: selectedToppings)
    }
    
    //MARK: Add custom toppings
    @IBAction func btnAddToppingPressed(_ sender: Any) {
        
        //setup alert to add topping
        let alertController = UIAlertController(title: "Add Topping!", message: "Add topping of your choice to build your custom pizza.", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: { alert -> Void in
            let txtField = alertController.textFields![0] as UITextField
            self.toppings.insert(txtField.text!, at: 0)
            //UserDefaults.standard.set(self.toppings, forKey: "toppings")
            
            self.toppingsPickerView.reloadAllComponents()
            
            CustomToppingsService.saveTopping(toppings: self.toppings.sorted())
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert -> Void in
        
            //Cancel action
        })
        
        //add textfield to alert
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Enter your topping:"
            textfield.addTarget(self, action: #selector(ToppingsViewController.textDidChange(txtfield:)), for: .editingChanged)
        }
        
        enableAction = saveAction
        saveAction.isEnabled = false
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Detect if textfield empty
    @objc func textDidChange(txtfield: UITextField)
    {
        //check if textfield has value
        enableAction.isEnabled = ((txtfield.text?.count)! > 0)
    }
    
    //MARK: Navigate to Custom Orders when notification is posted
    @objc func finishPassing() {
        
        DispatchQueue.main.async {
            self.navigationController?.tabBarController?.selectedIndex = 2
        }
        
    }
}

extension ToppingsViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return toppings.count
    }
}

extension ToppingsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return toppings[row]
    }
}

extension ToppingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedToppings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = selectedToppings[indexPath.row]
        return cell
    }
}

extension ToppingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }

        let removedTopping = selectedToppings.remove(at: indexPath.row)
        
        // update table view
        toppingsTableView.deleteRows(at: [indexPath], with: .automatic)
        
        toppings.append(removedTopping)
        toppings = toppings.sorted()
        
        toppingsPickerView.reloadAllComponents()
    }
    
}
