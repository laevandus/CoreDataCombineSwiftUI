//
//  ContentViewModel.swift
//  CoreDataCombineSwiftUI
//
//  Created by Toomas Vahter on 13.01.2020.
//  Copyright © 2020 Augmented Code. All rights reserved.
//

import Combine
import CoreData
import CoreGraphics
import SwiftUI
import UIKit

extension ContentView {
    final class ViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
        private let managedObjectContext: NSManagedObjectContext
        private let colorController: NSFetchedResultsController<ColorItem>
        
        init(managedObjectContext: NSManagedObjectContext) {
            self.managedObjectContext = managedObjectContext
            let sortDescriptors = [NSSortDescriptor(keyPath: \ColorItem.hex, ascending: true)]
            colorController = ColorItem.resultsController(context: managedObjectContext, sortDescriptors: sortDescriptors)
            super.init()
            colorController.delegate = self
            try? colorController.performFetch()
            observeChangeNotification()
        }
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            objectWillChange.send()
        }
        
        // MARK: Accessing Colors
        
        var colors: [ColorItem] {
            return colorController.fetchedObjects ?? []
        }
        
        @Published var selectedColorItem: ColorItem? = nil
        
        // MARK: Adding New Colors
        
        func addRandomColor() {
            // ColorItem requires hex to be set when saving the model in CoreData store.
            // Those 3 lines create a new ColorItem and save it.
            let color = ColorItem(context: managedObjectContext)
            color.hex = ColorItem.randomHex()
            managedObjectContext.saveIfNeeded()
            
            /*
            // Example of how to use KVO complient publisher and printing out a hex string (NSManagedObject is KVO complient).
            // Note that sink is triggered immediately and when property changes.
            let cancellable = color.publisher(for: \.hex).sink { (string) in
                print("Color item hex: \(string)")
            }
            cancellables.append(cancellable)
            
            // This triggers KVO change.
            color.hex = ColorItem.randomHex()
            
            // Keep context clean and save latest hex change.
            managedObjectContext.saveIfNeeded()
            */
        }
        
        // Observing Change Notifications
        
        private var cancellables = [AnyCancellable]()
        
        private func observeChangeNotification() {
            let cancellable = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
                .compactMap({ ManagedObjectContextChanges<ColorItem>(notification: $0) }).sink { (changes) in
                    print(changes)
            }
            cancellables.append(cancellable)
        }
    }
}

struct ManagedObjectContextChanges<T: NSManagedObject> {
    let inserted: Set<T>
    let deleted: Set<T>
    let updated: Set<T>
    
    init?(notification: Notification) {
        let unpack: (String) -> Set<T> = { key in
            let managedObjects = (notification.userInfo?[key] as? Set<NSManagedObject>) ?? []
            return Set(managedObjects.compactMap({ $0 as? T }))
        }
        deleted = unpack(NSDeletedObjectsKey)
        inserted = unpack(NSInsertedObjectsKey)
        updated = unpack(NSUpdatedObjectsKey).union(unpack(NSRefreshedObjectsKey))
        if deleted.isEmpty, inserted.isEmpty, updated.isEmpty {
            return nil
        }
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else { return }
        do {
            try save()
        }
        catch let nsError as NSError {
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension ColorItem {
    var uiColor: UIColor {
        return UIColor(hex: hex)!
    }
}

extension UIColor {
    convenience init?(hex: String) {
        guard let intValue = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else { return nil }
        self.init(red: CGFloat((intValue >> 16) & 0xff) / 255.0,
                  green: CGFloat((intValue >> 8) & 0xff) / 255.0,
                  blue: CGFloat(intValue & 0xff) / 255.0,
                  alpha: 1.0)
    }
}
