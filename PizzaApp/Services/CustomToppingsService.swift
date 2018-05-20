//
//  CustomToppingsService.swift
//  PizzaApp
//
//  Created by Admin on 5/19/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import Foundation
import Firebase

class CustomToppingsService{
    
    struct FireBaseToppingsKey {
        static let toppings = "custom-toppings"
    }
    
    static let ref = Database.database().reference(withPath: FireBaseToppingsKey.toppings)
    
    //MARK: Get all toppings
    class func getAllToppings(completion: @escaping ([String])->()){
        
        self.ref.observe(.value) { (snapshot) in
            
            var toppings: [String] = []
            
            toppings = snapshot.value as! [String]
            
            completion(toppings)
            
        }
    }
    
    //MARK: Save custom topping
    class func saveTopping(toppings: [String]){
        self.ref.setValue(toppings)
    }

    
    
}
