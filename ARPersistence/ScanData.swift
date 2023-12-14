//
//  ScanData.swift
//  ARPersistence
//
//  Created by Muhammad Mustafa on 03/12/2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation


struct ScanData:Identifiable {
    var id = UUID()
    let content:String
    
    init(content:String) {
        self.content = content
    }
}
