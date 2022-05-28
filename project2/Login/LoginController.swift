//
//  loginController.swift
//  project2
//
//  Created by Дмитрий Войтович on 14.04.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class LoginController: UIViewController {
    enum AuthState {
        case login
        case register
    }
    
    private var state: AuthState = .register
    
    private let firestore = Firestore.firestore()
    
    let registerButton: UIButton = {
        let registerButton = UIButton(type: .system)
        registerButton.backgroundColor = UIColor.init(red: 0/255, green: 70/255, blue: 0/255, alpha: 1)
        registerButton.tintColor = UIColor.systemYellow
        registerButton.setTitle("Register", for: .normal)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        return registerButton
    }()
    
    let authContentView: UIView = {
        let viewFirst = UIView()
        viewFirst.backgroundColor = UIColor.white | UIColor.lightGray
        viewFirst.translatesAutoresizingMaskIntoConstraints = false
        return viewFirst
    }()
    
    let buttonForRegisterBackground: UIButton = {
        let registerLogin = UIButton(type: .system)
        registerLogin.setTitle("Register", for: .normal)
        registerLogin.backgroundColor = UIColor.systemIndigo
        registerLogin.tintColor = UIColor.init(red: 239/255, green: 231/255, blue: 219/255, alpha: 1)
        registerLogin.translatesAutoresizingMaskIntoConstraints = false
        return registerLogin
    }()
    
    let buttonForLoginBackground: UIButton = {
        let loginRegister = UIButton(type: .system)
        loginRegister.setTitle("Login", for: .normal)
        loginRegister.backgroundColor = UIColor.init(red: 101/255, green: 67/255, blue: 33/255, alpha: 1)
        loginRegister.tintColor = UIColor.init(red: 239/255, green: 231/255, blue: 219/255, alpha: 1)
        loginRegister.translatesAutoresizingMaskIntoConstraints = false
        return loginRegister
    }()
    
    let nameContainerView = UIView()
    let textFieldName: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray | UIColor.white])

        tf.tintColor = UIColor.black | UIColor.white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailContainerView = UIView()
    let textFieldEmail: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray | UIColor.white])
        tf.tintColor = UIColor.black | UIColor.white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordContainerView = UIView()
    let textFieldPassword: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray | UIColor.white])
        tf.tintColor = UIColor.white | UIColor.black
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let nameSeparator = AuthSeparatorView()
    private let emailSeparator = AuthSeparatorView()
    lazy var authStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameContainerView,
                                                nameSeparator,
                                                emailContainerView,
                                                emailSeparator,
                                                passwordContainerView])
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.systemGray | UIColor.black
        setupConstraints()
        setupButtons()
    }
}

private extension LoginController {
    func setupButtons() {
        buttonForLoginBackground.addTarget(self, action: #selector(loginBackgroundButtonTapped), for: .touchUpInside)
        buttonForRegisterBackground.addTarget(self, action: #selector(registerBackgroundButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }
    
    @objc
    func loginBackgroundButtonTapped() {
        buttonForLoginBackground.backgroundColor = UIColor.systemIndigo
        buttonForRegisterBackground.backgroundColor = UIColor.init(red: 101/255, green: 67/255, blue: 33/255, alpha: 1)
        nameContainerView.isHidden = true
        nameSeparator.isHidden = true
        registerButton.setTitle("Login", for: .normal)
        textFieldPassword.isSecureTextEntry = true
        state = .login
    }
    
    @objc
    func registerBackgroundButtonTapped() {
        buttonForLoginBackground.backgroundColor = UIColor.init(red: 101/255, green: 67/255, blue: 33/255, alpha: 1)
        buttonForRegisterBackground.backgroundColor = UIColor.systemIndigo
        nameContainerView.isHidden = false
        nameSeparator.isHidden = false
        registerButton.setTitle("Register", for: .normal)
        textFieldPassword.isSecureTextEntry = false
        state = .register
    }
    
    @objc
    func handleRegister() {
        guard let email = textFieldEmail.text, let password = textFieldPassword.text, let name = textFieldName.text else {return}
        switch state {
        case .login:
            login(email: email, password: password)
        case .register:
            register(name: name, email: email, password: password)
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let self = self else { return }
            if error != nil {
                print(error!)
            } else {
                navigation.switchToMain()
            }
        }
    }
    
    func register(name: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let authResult = authResult {
                let user = authResult.user
                
                let data: [String: Any] = [
                    "name": name,
                    "email": email
                ]
                self.firestore.collection("users").document(user.uid).setData(data) { error in
                    if error != nil {
                        print("\(String(describing: error))")
                    }
                }
            }
            if error != nil {
                print("\(String(describing: error))")
                return
            }
            navigation.switchToMain()
        }
    }
}

private extension LoginController {
    func setupConstraints() {
        view.addSubview(authContentView)
        view.addSubview(registerButton)
        view.addSubview(buttonForRegisterBackground)
        view.addSubview(buttonForLoginBackground)
        authContentView.addSubview(authStackView)
        nameContainerView.addSubview(textFieldName)
        emailContainerView.addSubview(textFieldEmail)
        passwordContainerView.addSubview(textFieldPassword)
        
        authContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        authContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        authContentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        authContentView.layer.cornerRadius = 16
        
        registerButton.topAnchor.constraint(equalTo: authContentView.bottomAnchor, constant: 12).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: authContentView.centerXAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: authContentView.widthAnchor, multiplier: 0.7).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        registerButton.layer.cornerRadius = 22
        
        buttonForRegisterBackground.bottomAnchor.constraint(equalTo: authContentView.topAnchor, constant: -8).isActive = true
        buttonForRegisterBackground.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        buttonForRegisterBackground.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonForRegisterBackground.widthAnchor.constraint(equalTo: authContentView.widthAnchor, multiplier: 0.45).isActive = true
        buttonForRegisterBackground.layer.cornerRadius = 12
        
        buttonForLoginBackground.bottomAnchor.constraint(equalTo: authContentView.topAnchor, constant: -8).isActive = true
        buttonForLoginBackground.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        buttonForLoginBackground.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonForLoginBackground.widthAnchor.constraint(equalTo: authContentView.widthAnchor, multiplier: 0.45).isActive = true
        buttonForLoginBackground.layer.cornerRadius = 12
        
        authStackView.topAnchor.constraint(equalTo: authContentView.topAnchor).isActive = true
        authStackView.leftAnchor.constraint(equalTo: authContentView.leftAnchor).isActive = true
        authStackView.rightAnchor.constraint(equalTo: authContentView.rightAnchor).isActive = true
        authStackView.bottomAnchor.constraint(equalTo: authContentView.bottomAnchor).isActive = true
        
        textFieldName.topAnchor.constraint(equalTo: nameContainerView.topAnchor, constant: 12).isActive = true
        textFieldName.leftAnchor.constraint(equalTo: nameContainerView.leftAnchor, constant: 12).isActive = true
        textFieldName.rightAnchor.constraint(equalTo: nameContainerView.rightAnchor, constant: -12).isActive = true
        textFieldName.bottomAnchor.constraint(equalTo: nameContainerView.bottomAnchor, constant: -12).isActive = true
        
        textFieldEmail.topAnchor.constraint(equalTo: emailContainerView.topAnchor, constant: 12).isActive = true
        textFieldEmail.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor, constant: 12).isActive = true
        textFieldEmail.rightAnchor.constraint(equalTo: emailContainerView.rightAnchor, constant: -12).isActive = true
        textFieldEmail.bottomAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: -12).isActive = true
        
        textFieldPassword.topAnchor.constraint(equalTo: passwordContainerView.topAnchor, constant: 12).isActive = true
        textFieldPassword.leftAnchor.constraint(equalTo: passwordContainerView.leftAnchor, constant: 12).isActive = true
        textFieldPassword.rightAnchor.constraint(equalTo: passwordContainerView.rightAnchor, constant: -12).isActive = true
        textFieldPassword.bottomAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: -12).isActive = true
    }
}

private class AuthSeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 1.0 / UIScreen.main.scale)
    }
}
