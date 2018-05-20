//
//  CustomPizzaOrder.swift
//  PizzaApp
//
//  Created by Admin on 5/19/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import Foundation
import Firebase

struct CustomPizzaOrder {
    
    let ref: DatabaseReference?
    let key: String
    let toppings: [String]
    let date: String
    let favorite: Bool

    
    init(toppings: [String], addedOn: String, favorite: Bool, key: String = "") {
        self.ref = nil
        self.key = key
        self.toppings = toppings
        self.date = addedOn
        self.favorite = favorite
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let toppings = value["toppings"] as? [String],
            let date = value["addedOn"] as? String,
            let favorite = value["favorite"] as? Bool else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.toppings = toppings
        self.date = date
        self.favorite = favorite
    }
    
    func toAnyObject() -> Any {
        return [
            "toppings": toppings,
            "addedOn": date,
            "favorite": favorite
        ]
    }
}
