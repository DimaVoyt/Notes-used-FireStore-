//
//  NotesListViewController.swift
//  project2
//
//  Created by Дмитрий Войтович on 14.04.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NotesListViewController: UIViewController {
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var notes = [Note]()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var notesListenerRegistration: ListenerRegistration?
    
    deinit {
        notesListenerRegistration?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false

        tableView.register(NotesCell.self, forCellReuseIdentifier: "noteCell")
        
        setupConstraints()
        setupNavigationTitle()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        addNotesListener()
    }
    
    @objc func addNote() {
        let addNoteViewController = NotesViewController()
        navigationController?.pushViewController(addNoteViewController, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {}
        navigation.switchToLogin()
    }
}

extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NotesCell
        cell.setup(with: notes[indexPath.row])
        return cell
    }
}

extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notes[indexPath.row]
        let noteInfoViewController = NotesInformationViewController(note: note)
        navigationController?.pushViewController(noteInfoViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, swipeButtonView, completion in
            guard let self = self else { return }
            
            let note = self.notes[indexPath.row]
            self.firestore.collection("notes").document(note.id).delete() { err in
                if err != nil {
                    print(err!)
                } else {
                    print("Good")
                }
            }

            completion(true)
        } 
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

private extension NotesListViewController {
    func setupNavigationTitle() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "plus"), style: .plain, target: self, action: #selector(addNote))
        
        guard let currentUser = auth.currentUser else { return }
        
        firestore.collection("users").document(currentUser.uid)
            .getDocument { [weak self] snapshot, error in
                guard let self = self, let userData = snapshot?.data() else { return }
                
                let name = userData["name"] as? String
                self.title = name
        }
    }
    
    func addNotesListener() {
        guard let currentUser = auth.currentUser else { return }
        
        notesListenerRegistration = firestore.collection("notes")
            .whereField("userUid", isEqualTo: currentUser.uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else { return }
                
                let documents = snapshot.documents.map { $0.data() }
                let notes = documents.map { values -> Note in
                    return Note(id: values["id"] as? String ?? "",
                                title: values["title"] as? String ?? "",
                                text: values["text"] as? String ?? "")
                }
                
                self.notes = notes
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

private extension NotesListViewController {
    func setupConstraints() {
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
