//
//  SelectedColorView.swift
//  CoreDataCombineSwiftUI
//
//  Created by Toomas Vahter on 13.01.2020.
//  Copyright © 2020 Augmented Code. All rights reserved.
//

import SwiftUI

struct SelectedColorView: View {
    @ObservedObject var colorItem: ColorItem
    
    var body: some View {
        ZStack {
            Color(colorItem.uiColor)
            Button(action: randomise) {
                Text("Randomise")
            }
        }
    }
    
    private func randomise() {
        colorItem.hex = ColorItem.randomHex()
        colorItem.managedObjectContext?.saveIfNeeded()
    }
}

//struct SelectedColorView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectedColorView()
//    }
//}
