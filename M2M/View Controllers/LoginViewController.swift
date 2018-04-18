//
//  LoginViewController.swift
//  thePrototype
//
//  Created by Tran Sam on 9/21/17.
//  Copyright © 2017 Tran Sam. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = [usernameField, passwordField].map { $0.delegate = self }
        autoFillFields()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        samLogin()
    }
    
    func autoFillFields() {
        if let loginTuple = Defaults.manager.autoFillTextFields() {
            usernameField.text = loginTuple.0
            passwordField.text = loginTuple.1
        }
    }
    
    func samLogin() {
        loginButton.isEnabled = false
        guard let loginName = usernameField.text, let loginPassword = passwordField.text else {
            loginButton.isEnabled = true
            return
        }
        
        let  loginInfo = PatientCredential(email: loginName, password: loginPassword)
        var login = RestApiManager()
        
        login.stringURL = "https://apiserver269.herokuapp.com/auth/local"
        login.login(withCredentials: loginInfo) { tempData in
            print(tempData)
            let loginData = tempData
            
            DispatchQueue.main.async {
                let auth = AuthData.auth
                auth.setLogin(loginData)

                guard let userID = auth.getUserID() else { return }
                
                print("Date: \(Date.timeIntervalSinceReferenceDate)")
                
                print("Login data is \(String(describing: userID))")
                Defaults.manager.saveToDefaults(loginInfo)
                self.present(mainVC, animated: true) { [unowned self] in
                    self.loginButton.isEnabled = true

                    SelectedExercise.manager.populateExercises()
                    // NOTE: Vic's non-unit test
                    AssignmentAPIHelper.manager.getAssignments("d19c786f-633a-44ba-98ab-0d207592c4cc", completionHandler: {
                        print($0)
                    }, errorHandler: {
                        print($0)
                    })
                    // NOTE: End testing here
                }
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
            samLogin()
        default:
            break
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = true
    }
}