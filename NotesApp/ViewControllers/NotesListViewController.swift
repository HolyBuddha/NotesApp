//
//  NotesList.swift
//  NotesApp
//
//  Created by Vladimir Izmaylov on 06.02.2022.
//

import UIKit
import CoreData

class NotesListViewController: UITableViewController {
    
    //MARK: - Private properties
    
    private var notesList: [Note] = []
    private var segmentedControlIndex = 0
    
    // MARK: Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        if notesList.count == 0 { save("New note") }
        reloadData()
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        content.text = note.text
        content.secondaryText = dateFormatter.string(from: (note.date ?? NSDate.now))
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notesList[indexPath.row]
        showEditAlert(note)
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
            StorageManager.shared.delete(note)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeActions
    }
    
    //MARK: - IB Actions
    
    @IBAction func sortNoteList(_ sender: UISegmentedControl) {
        segmentedControlIndex = sender.selectedSegmentIndex
        reloadData()
    }
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new note", message: "Please enter text", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let note = alert.textFields?.first?.text, !note.isEmpty else { return }
            self.save(note)
            self.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Note"
        }
        present(alert, animated: true)
    }
}
extension NotesListViewController {
    
    // MARK: Private Methods
    
    private func save(_ noteName: String) {
        StorageManager.shared.save(noteName) { note in
            self.notesList.append(note)
            let cellIndex = IndexPath(row: notesList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let notes):
                self.notesList = notes
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func reloadData() {
        notesList = segmentedControlIndex == 0
        ? notesList.sorted(by: { $0.text?.lowercased() ?? "a" < $1.text?.lowercased() ?? "b"})
        : notesList.sorted(by: { $0.date ?? NSDate.now > $1.date ?? NSDate.now })
        tableView.reloadData()
    }
    
    // MARK: - AlertController
    
    private func showEditAlert(_ noteForCell: Note) {
        let alert = UIAlertController(title: "Edit this note", message: "Please enter text", preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let note = alert.textFields?.first?.text, !note.isEmpty else { return }
            StorageManager.shared.edit(noteForCell, newName: note)
            self.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Edit Note"
            textField.text = noteForCell.text
        }
        present(alert, animated: true)
    }
    
}
