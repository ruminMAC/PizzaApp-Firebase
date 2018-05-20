//
//  Date.swift
//  HealthcareApp
//
//  Created by mac on 5/18/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation


fileprivate struct Formatter{
    
    static var myFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return formatter
    }
}

extension Date {
    
    var toString: String {
        return Formatter.myFormatter.string(from: self)
    }
}
