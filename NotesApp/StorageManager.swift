//
//  StorageManager.swift
//  NotesApp
//
//  Created by Vladimir Izmaylov on 06.02.2022.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotesCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private let viewContext: NSManagedObjectContext

    private init () { viewContext = persistentContainer.viewContext }
    

    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
