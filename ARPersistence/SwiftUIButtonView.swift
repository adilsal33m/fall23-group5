//
//  SwiftUIButtonView.swift
//  ARPersistence
//
//  Created by Muhammad Mustafa on 14/12/2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct SwiftUIButtonView: View {
    var onButtonTap: () -> Void

    var body: some View {
        Button("Show Timetable") {
            onButtonTap()
        }
        .frame(width: 150, height: 38.5)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
