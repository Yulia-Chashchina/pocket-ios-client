//
//  SignUpViewController.swift
//  pocket-ios-client
//
//  Created by Anya on 01/11/2018.
//  Copyright © 2018 Damien Inc. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!

    var user: User!
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "screenImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2071147859, green: 0.5941259265, blue: 0.8571158051, alpha: 1)
        setupLayout()
        setupBackButton()
        
        
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
       
        backButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            ])
    }
    
    private func setupLayout() {
        let topImageContainerView = UIView()
        view.addSubview(topImageContainerView)
        topImageContainerView.translatesAutoresizingMaskIntoConstraints = false
        topImageContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topImageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topImageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
       topImageContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        topImageContainerView.addSubview(imageView)
       
        imageView.centerXAnchor.constraint(equalTo: topImageContainerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: topImageContainerView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: topImageContainerView.heightAnchor, multiplier: 0.65).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        
        loginTextField.placeholder = "Login"
        emailTextField.placeholder = "E-mail"
        passwordTextField.placeholder = "Password"
        
        loginTextField.topAnchor.constraint(equalTo: topImageContainerView.bottomAnchor).isActive = true
        loginTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true

        emailTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signUpButton.titleLabel?.font = UIFont(name: "Roboto.regular", size: 16)
        signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -43).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    

    @IBAction func backButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SignUpButtonPress(_ sender: Any) {
        guard let account_name = loginTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {return}
        guard !account_name.isEmpty, !email.isEmpty, !password.isEmpty else {
            print ("fill the data in fields")
            self.showErrorAlert(message: "Не все поля заполнены")
            return
        }
        
        UserSelf.account_name = account_name
        UserSelf.email = email
        UserSelf.password = password
        
        NetworkServices.signUp { (token, statusCode) in
            if (token != "") && (statusCode == 201) {
                Token.token = token
                NetworkServices.getSelfUser(token: token) { (json, statusCode) in
                    if statusCode == 200 {
                        DataBase.saveSelfUser(json: json)
                    } else {
                        print ("GetSelfUser error")
                    }
                }
                DispatchQueue.main.async {
                    let tabBarVC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    
                    self.present(tabBarVC, animated:true, completion:nil)
                }
            }
            else {
                if statusCode == 409 {
                    print ("user already exists")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Пользователь уже существует")
                    }
                } else if statusCode == 400 {
                    print ("bad JSON")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Не все поля заполнены")
                    }
                } else {
                    print ("signUp error")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Ошибка соединения с сервером")
                    }
                }
                
            }
        }
    }
    
    //алерт с ошибкой
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
