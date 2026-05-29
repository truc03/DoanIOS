//
//  LoginViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Setup
    private func setupUI() {
        // Secure Password
        txtPassword.isSecureTextEntry = true
        
        // Beautiful Premium Styling
        view.backgroundColor = .systemBackground
        
        txtUsername.layer.cornerRadius = 8
        txtUsername.clipsToBounds = true
        txtUsername.borderStyle = .roundedRect
        txtUsername.autocapitalizationType = .none
        
        txtPassword.layer.cornerRadius = 8
        txtPassword.clipsToBounds = true
        txtPassword.borderStyle = .roundedRect
        txtPassword.autocapitalizationType = .none
        
        btnLogin.layer.cornerRadius = 10
        btnLogin.clipsToBounds = true
        btnLogin.backgroundColor = .systemBlue
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        // Shadow for premium look
        btnLogin.layer.shadowColor = UIColor.systemBlue.cgColor
        btnLogin.layer.shadowOpacity = 0.3
        btnLogin.layer.shadowOffset = CGSize(width: 0, height: 4)
        btnLogin.layer.shadowRadius = 8
        
        // Tap actions
        btnLogin.addTarget(self, action: #selector(btnSubmitLogin), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func btnSubmitLogin() {
        guard let username = txtUsername.text, !username.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
            showAlert(title: "Thông báo", message: "Vui lòng nhập đầy đủ tài khoản và mật khẩu")
            return
        }
        
        // Show Loading Indicator or disable button
        btnLogin.isEnabled = false
        btnLogin.alpha = 0.7
        
        FirebaseService.shared.loginUser(username: username, password: password) { [weak self] success, email, error in
            guard let self = self else { return }
            self.btnLogin.isEnabled = true
            self.btnLogin.alpha = 1.0
            
            if success {
                // Save session
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(username, forKey: "currentUsername")
                if let email = email {
                    UserDefaults.standard.set(email, forKey: "currentEmail")
                }
                
                // Dismiss modal login to return to admin dashboard
                self.dismiss(animated: true, completion: nil)
            } else {
                let errorMsg = error?.localizedDescription ?? "Đăng nhập thất bại"
                self.showAlert(title: "Lỗi đăng nhập", message: errorMsg)
            }
        }
    }
    
    @IBAction func tapToRegister(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func tapToProblemAccount(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProblemAccountViewController") as? ProblemAccountViewController {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
