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
    
    // MARK: - Public Methods
    
    // fetch data
    func fetchData(completion: (Result<[Note], Error>) -> Void) {
        let fetchRequest = Note.fetchRequest()
        
        do {
            let notes = try viewContext.fetch(fetchRequest)
            completion(.success(notes))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // save data
    func save(_ noteName: String, completion: (Note) -> Void) {
        let note = Note(context: viewContext)
        note.text = noteName
        completion(note)
        saveContext()
    }
    
    // edit data
    func edit(_ note: Note, newName: String) {
        note.text = newName
        saveContext()
    }
    
    // delete data
    func delete(_ note: Note) {
        viewContext.delete(note)
        saveContext()
    }

    // MARK: - Core Data Saving support
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
