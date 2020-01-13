//
//  ContentView.swift
//  CoreDataCombineSwiftUI
//
//  Created by Toomas Vahter on 13.01.2020.
//  Copyright © 2020 Augmented Code. All rights reserved.
//

import Combine
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.colors, id: \.objectID) { (colorItem) in
                    Cell(colorItem: colorItem).onTapGesture {
                        self.viewModel.selectedColorItem = colorItem
                    }
                }
                if viewModel.selectedColorItem != nil {
                    SelectedColorView(colorItem: viewModel.selectedColorItem!).frame(minHeight: 50, maxHeight: 50)
                }
            }.navigationBarTitle("Colors")
                .navigationBarItems(trailing: trailingBarItem)
        }
    }
    
    private var trailingBarItem: some View {
        Button(action: viewModel.addRandomColor, label: {
            Text("Add")
        })
    }
}

struct Cell: View {
    @ObservedObject var colorItem: ColorItem
    
    var body: some View {
        HStack {
            Text(verbatim: colorItem.hex)
            Spacer()
            Rectangle().foregroundColor(Color(colorItem.uiColor)).frame(minWidth: 50, maxWidth: 50)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let dependencyContainer = DependencyContainer()
    
    static var previews: some View {
        let context = dependencyContainer.persistentContainer.viewContext
        let viewModel = ContentView.ViewModel(managedObjectContext: context)
        return ContentView(viewModel: viewModel)
    }
}
