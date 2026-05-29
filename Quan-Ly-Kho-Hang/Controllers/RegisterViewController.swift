//
//  RegisterViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        txtPassword.isSecureTextEntry = true
        txtRePassword.isSecureTextEntry = true
        txtEmail.keyboardType = .emailAddress
        txtEmail.autocapitalizationType = .none
        txtUsername.autocapitalizationType = .none
        
        [txtUsername, txtEmail, txtPassword, txtRePassword].forEach { tf in
            tf?.layer.cornerRadius = 8
            tf?.borderStyle = .roundedRect
        }
        
        btnRegister.layer.cornerRadius = 10
        btnRegister.clipsToBounds = true
        btnRegister.backgroundColor = .systemGreen
        btnRegister.setTitleColor(.white, for: .normal)
        btnRegister.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btnRegister.layer.shadowColor = UIColor.systemGreen.cgColor
        btnRegister.layer.shadowOpacity = 0.3
        btnRegister.layer.shadowOffset = CGSize(width: 0, height: 4)
        btnRegister.layer.shadowRadius = 8
        
        btnRegister.addTarget(self, action: #selector(btnSubmitRegister), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func btnSubmitRegister() {
        guard let username = txtUsername.text, !username.isEmpty else {
            showAlert(message: "Vui lòng nhập tên tài khoản"); return
        }
        guard let email = txtEmail.text, !email.isEmpty, isValidEmail(email) else {
            showAlert(message: "Vui lòng nhập email hợp lệ"); return
        }
        guard let password = txtPassword.text, password.count >= 6 else {
            showAlert(message: "Mật khẩu phải có ít nhất 6 ký tự"); return
        }
        guard let rePassword = txtRePassword.text, rePassword == password else {
            showAlert(message: "Mật khẩu nhập lại không khớp"); return
        }
        
        btnRegister.isEnabled = false
        btnRegister.alpha = 0.7
        
        FirebaseService.shared.registerUser(username: username, email: email, password: password) { [weak self] error in
            guard let self = self else { return }
            self.btnRegister.isEnabled = true
            self.btnRegister.alpha = 1.0
            
            if let error = error {
                self.showAlert(message: error.localizedDescription)
            } else {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(username, forKey: "currentUsername")
                UserDefaults.standard.set(email, forKey: "currentEmail")

                let alert = UIAlertController(title: "Thành công", message: "Tài khoản đã được tạo và đăng nhập.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    let loginViewController = self.presentingViewController
                    self.dismiss(animated: true) {
                        loginViewController?.dismiss(animated: true)
                    }
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func tapToLogin(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
