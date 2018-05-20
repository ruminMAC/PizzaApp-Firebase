//
//  ActivityIndicatorService.swift
//  PizzaApp
//
//  Created by Admin on 5/20/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit

class ActivityIndicatorService{
    
    var indicator = UIActivityIndicatorView()
    
    static let shared = ActivityIndicatorService(activityIndicator: UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60)))
    
    private init(activityIndicator:  UIActivityIndicatorView){
        indicator = activityIndicator
        indicator.activityIndicatorViewStyle = .gray
    }
}
