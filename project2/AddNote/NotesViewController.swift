//
//  NotesViewController.swift
//  project2
//
//  Created by Дмитрий Войтович on 16.04.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NotesViewController: UIViewController {
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    let ViewForTextField: UIView = {
        let viewFirst = UIView()
        viewFirst.backgroundColor = UIColor.lightGray | UIColor.lightGray
        viewFirst.translatesAutoresizingMaskIntoConstraints = false
        return viewFirst
    }()
    let nameTextField: UITextField = {
       let name = UITextField()
        name.placeholder = "Note name"
        name.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white | UIColor.white])

        name.backgroundColor = UIColor.lightGray | UIColor.lightGray
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    let ViewForNoteText: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray | UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let noteText: UITextView = {
        let noteText = UITextView()
//        noteText.placeholder = "Type text"
        noteText.backgroundColor = UIColor.lightGray | UIColor.lightGray
        noteText.translatesAutoresizingMaskIntoConstraints = false
        return noteText
    }()
    
    let saveNoteInformationButton: UIButton = {
       let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appBlue
        button.tintColor = UIColor.systemMint
        return button
    }()
    
    @objc func saveInfoNotes() {
        guard let noteName = nameTextField.text,
              let noteText = noteText.text,
              let currentUser = Auth.auth().currentUser else { return }
        
        
        let noteDoc = self.firestore.collection("notes").document()
        
        let data: [String: Any] = [
            "id": noteDoc.documentID,
            "title": noteName,
            "text": noteText,
            "userUid": currentUser.uid,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        noteDoc.setData(data)
        navigation.switchToMain()
        
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = UIColor.white | UIColor.black
        setupNavigationTitle()
        setupConstraints()
        setupKeyboardWillShow()
        setupKeyboardWillHide()
        setupButtons()
    }
    

}

var saveNoteInformationButtonBottomAnchor: NSLayoutConstraint?

private extension NotesViewController {
    
    func setupButtons() {
        saveNoteInformationButton.addTarget(self, action: #selector(saveInfoNotes), for: .touchUpInside)

    }
    
    func setupConstraints() {
        view.addSubview(ViewForTextField)
        ViewForTextField.addSubview(nameTextField)
        view.addSubview(ViewForNoteText)
        ViewForNoteText.addSubview(noteText)
        view.addSubview(saveNoteInformationButton)
        
        ViewForTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ViewForTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        ViewForTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        ViewForTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ViewForTextField.layer.cornerRadius = 16
        
        nameTextField.topAnchor.constraint(equalTo: ViewForTextField.topAnchor, constant: 12).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: ViewForTextField.bottomAnchor, constant: -12).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: ViewForTextField.leftAnchor, constant: 12).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: ViewForTextField.rightAnchor, constant: -12).isActive = true
        
        ViewForNoteText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ViewForNoteText.topAnchor.constraint(equalTo: ViewForTextField.bottomAnchor, constant: 8).isActive = true
        ViewForNoteText.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        ViewForNoteText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        ViewForNoteText.layer.cornerRadius = 22
        
        noteText.topAnchor.constraint(equalTo: ViewForNoteText.topAnchor, constant: 12).isActive = true
        noteText.bottomAnchor.constraint(equalTo: ViewForNoteText.bottomAnchor, constant: -12).isActive = true
        noteText.leftAnchor.constraint(equalTo: ViewForNoteText.leftAnchor, constant: 12).isActive = true
        noteText.rightAnchor.constraint(equalTo: ViewForNoteText.rightAnchor, constant: -12).isActive = true
        
        saveNoteInformationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveNoteInformationButtonBottomAnchor = saveNoteInformationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        saveNoteInformationButtonBottomAnchor?.isActive = true
        saveNoteInformationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveNoteInformationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
        saveNoteInformationButton.layer.cornerRadius = 15
        
    }
    
    func setupNavigationTitle() {
        guard let currentUser = auth.currentUser else { return }
        
        firestore.collection("users").document(currentUser.uid)
            .getDocument { [weak self] snapshot, error in
                guard let self = self, let userData = snapshot?.data() else { return }
                
                let name = userData["name"] as? String
                self.title = name
        }
    }
    
    func setupKeyboardWillShow() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: handleKeyboardWillShow)
    }
    func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let height = keyboardFrame.cgRectValue.height
        saveNoteInformationButtonBottomAnchor?.constant = -height
    }
    
    func setupKeyboardWillHide() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: handleKeyboardWillHide)
    }
    func handleKeyboardWillHide(notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//        let height = keyboardFrame.cgRectValue.height
        saveNoteInformationButtonBottomAnchor?.constant = -50
        
    }
    
}
