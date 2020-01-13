//
//  ColorItem.swift
//  CoreDataCombineSwiftUI
//
//  Created by Toomas Vahter on 13.01.2020.
//  Copyright © 2020 Augmented Code. All rights reserved.
//

import CoreData

final class ColorItem: NSManagedObject {
    @NSManaged var hex: String
}

extension ColorItem {
    static func randomHex() -> String {
        let characters = "0123456789ABCDEF"
        return "#" + (0..<6).map({ _ in characters.randomElement()! })
    }
}

extension ColorItem {
    static let entityName = "ColorItem"
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
    static func makeRequest() -> NSFetchRequest<ColorItem> {
        return NSFetchRequest<ColorItem>(entityName: entityName)
    }
    
    static func resultsController(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) -> NSFetchedResultsController<ColorItem> {
        let request = makeRequest()
        request.sortDescriptors = sortDescriptors.isEmpty ? nil : sortDescriptors
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
