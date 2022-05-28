//
//  NotesInformationViewController.swift
//  project2
//
//  Created by Дмитрий Войтович on 19.04.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NotesInformationViewController: UIViewController {
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    var saveChangesButtonBottomAnchor: NSLayoutConstraint?
    private let note: Note
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let viewNoteInf: UIView = {
        let VNI = UIView()
        VNI.backgroundColor = UIColor.gray | UIColor.gray
        VNI.translatesAutoresizingMaskIntoConstraints = false
        return VNI
    }()
    
    let viewNoteInfoText: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.white | UIColor.black
        tv.font = .systemFont(ofSize: 25, weight: .thin)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let saveChangesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save changes", for: .normal)
        button.backgroundColor = UIColor.brown
        button.tintColor = UIColor.systemMint
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 8
        return button
    }()
    
    @objc func saveInfo() {
        updateNoteText()
        navigation.switchToMain()
    }
    
    func updateNoteText() {
        guard let updatedText = viewNoteInfoText.text else { return }
        let update = firestore.collection("notes").document(note.id)
        update.updateData(["text": updatedText]) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleName()
        setupconstraintsForInf()
        viewNoteInfoText.text = note.text
        setupKeyboardHandlers()
        setupButton()
    }
    
    func setupKeyboardHandlers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: handleKeyboardWillShow)
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil,
            using: handleKeyboardWillHide
        )
    }
    
    func handleKeyboardWillShow(
        notification: Notification
    ) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let height = keyboardFrame.cgRectValue.height
        saveChangesButtonBottomAnchor?.constant = -height + safeAreaInsets.bottom
    }
    
    func handleKeyboardWillHide(
        notification: Notification
    ) {
        saveChangesButtonBottomAnchor?.constant = -12
    }
    
    func setupButton() {
        saveChangesButton.addTarget(self, action: #selector(saveInfo), for: .touchUpInside)
    }
    
    func setupconstraintsForInf() {
        view.addSubview(viewNoteInf)
        viewNoteInf.addSubview(viewNoteInfoText)
        view.addSubview(saveChangesButton)
        
        viewNoteInf.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        viewNoteInf.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewNoteInf.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viewNoteInf.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        viewNoteInfoText.topAnchor.constraint(equalTo: viewNoteInf.topAnchor).isActive = true
        viewNoteInfoText.bottomAnchor.constraint(equalTo: viewNoteInf.bottomAnchor, constant: -100).isActive = true
        viewNoteInfoText.leftAnchor.constraint(equalTo: viewNoteInf.leftAnchor).isActive = true
        viewNoteInfoText.rightAnchor.constraint(equalTo: viewNoteInf.rightAnchor).isActive = true

        saveChangesButtonBottomAnchor = saveChangesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
            saveChangesButtonBottomAnchor?.isActive = true
        saveChangesButton.centerXAnchor.constraint(equalTo: viewNoteInf.centerXAnchor).isActive = true
    }
    
    func titleName() {
        firestore.collection("notes").document(note.id)
            .getDocument { [weak self] snapshot, error in
                guard let self = self, let userData = snapshot?.data() else { return }
                let title = userData["title"] as? String
                self.title = title
        }
    }
}

var safeAreaInsets: UIEdgeInsets {
    let window = UIApplication.shared.keyWindow
    return window?.safeAreaInsets ?? .zero
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}
