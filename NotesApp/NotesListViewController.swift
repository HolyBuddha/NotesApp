//
//  NotesList.swift
//  NotesApp
//
//  Created by Vladimir Izmaylov on 06.02.2022.
//

import UIKit
import CoreData

class NotesListViewController: UITableViewController {
    
    //Вынеси всю работу с coreData в StorageManager
    
    private let context = StorageManager.shared.persistentContainer.viewContext
    private var notesList: [Note] = []
    
  

    @IBAction func addNote(_ sender: UIBarButtonItem) {
            let alert = UIAlertController(title: "Add new note", message: "Please enter text", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let note = alert.textFields?.first?.text, !note.isEmpty else { return }
                self.save(note)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
            present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        if notesList.count == 0 { save("New note") }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { notesList.count }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let note = notesList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = note.text
        cell.contentConfiguration = content
        return cell
    }
}

extension NotesListViewController {
    
    private func save(_ noteName: String) {
    
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return }
        guard let note = NSManagedObject(entity: entityDescription, insertInto: context) as? Note else { return }
        note.text = noteName
        notesList.append(note)
        
        let cellIndex = IndexPath(row: notesList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func delete(_ note: Note) {
        context.delete(note)
        StorageManager.shared.saveContext()
    }
    
    private func edit(note: Note, with noteName: String) {
        note.text = noteName
        StorageManager.shared.saveContext()
        reloadData()
    }
    
    private func fetchData() {
        let fetchRequest = Note.fetchRequest()
        do {
            notesList = try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let note = notesList[indexPath.row]
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, boolValue) in
            self.showEditAlert(note)
            boolValue(true)
        }
        
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            
            self.notesList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.delete(note)
        }
            
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeActions
    }
    
    
    private func showEditAlert(_ noteForCell: Note) {
    let alert = UIAlertController(title: "Edit this note", message: "Please enter text", preferredStyle: .alert)
    let editAction = UIAlertAction(title: "Save", style: .default) { _ in
        guard let note = alert.textFields?.first?.text, !note.isEmpty else { return }
        self.edit(note: noteForCell, with: note)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    alert.addAction(editAction)
    alert.addAction(cancelAction)
    alert.addTextField { textField in
        textField.placeholder = "Edit Note"
    }
    present(alert, animated: true)
        
    }
    
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}
