//
//  PizzaService.swift
//  PizzaApp
//
//  Created by mac on 5/8/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import Firebase

typealias PizzaHandler = ([(Pizza, Int)])->Void

class PizzaService {
    
    //static var delegate: PizzaServiceDelegate?
    
    static var isPizzaSaved = false
    
    struct FireBaseKey
    {
        struct ReferenceKey {
            static let pizzaOrders = "pizza-orders"
            static let toppings = "toppings"
            static let date = "orderedOn"
            static let favorite = "favorite"
        }
    }
    
    static let ref = Database.database().reference(withPath: FireBaseKey.ReferenceKey.pizzaOrders)
    

    //MARK: Get Pizzas based on selected index of segment control
    class func getPizzas(limit: Int = 20, sort: Int, completion: @escaping PizzaHandler){
        DispatchQueue.global(qos: .userInitiated).async {
            
            //get pizza orders from .json
            guard let path = Bundle.main.path(
                forResource: "pizzas",
                ofType: "json") else {
                return
            }
            
            let fileURL = URL(fileURLWithPath: path)
            
            var pizzas: [Pizza]
            do {
                let data = try Data(contentsOf: fileURL)
                pizzas = try JSONDecoder().decode([Pizza].self, from: data)
            } catch  {
                print(error.localizedDescription)
                return
            }
            
            //count the number of orders
            let counts = pizzas.reduce(into: [Pizza: Int]()){ $0[$1, default: 0] += 1}
            
            
            var topPizzas = [(Pizza,Int)]()
            
            // sort all pizzas by Descending Order
            if sort == 0
            {
                topPizzas = counts.sorted(by: { $0.value < $1.value })
            }
            
            // sort all pizzas by Descending Order
            else if sort == 1
            {
                topPizzas = counts.sorted(by: { $0.value > $1.value })
            }

            //sort all pizzas alphabetically
            else
            {
                topPizzas = counts.sorted(by: { $0.key < $1.key })
            }
            
            // if the limit is greater than the count, we will crash
            let end = min(limit, topPizzas.count)
            
            // return the top N pizzas
            completion(Array(topPizzas[0..<end]))
        }
    }
    
    //MARK: Get all orders
    class func getAllOrders(completion: @escaping ([CustomPizzaOrder])->()){
        
        self.ref.observe(.value) { (snapshot) in

            var orders: [CustomPizzaOrder] = []
            
            for child in snapshot.children
            {
                if let snapshot = child as? DataSnapshot, let pizzaOrder = CustomPizzaOrder(snapshot: snapshot){
                    orders.append(pizzaOrder)
                }
            }
        
            completion(orders)
            
        }
    }
    
    //MARK: Delete order
    class func deletePizzaOrder(index: Int, pizzaOrder: CustomPizzaOrder){
        
        pizzaOrder.ref?.removeValue()
        NotificationCenter.default.post(name: Notification.Name("deleted"), object: nil)
    }
    
    //MARK: Update order
    class func updatePizzaOrder(favorite: Bool, pizzaOrder: CustomPizzaOrder){
        
        pizzaOrder.ref?.updateChildValues([PizzaService.FireBaseKey.ReferenceKey.favorite:favorite])
        
    }
    
    //MARK: Save custom order
    class func saveOrder(toppings: [String]){
        
        let pizzaOrder = CustomPizzaOrder(toppings: toppings, addedOn: Date().toString, favorite: false)

        let pizzaOrderRef =  self.ref.childByAutoId()
        
        //self.ref.child(PizzaService.FireBaseKey.ReferenceKey.childKey)
        
        pizzaOrderRef.setValue(pizzaOrder.toAnyObject())
        
        NotificationCenter.default.post(name: Notification.Name("saved"), object: nil)
        
    }

}
