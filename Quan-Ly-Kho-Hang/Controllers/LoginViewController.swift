//
//  LoginViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit
import OSLog

class LoginViewController: UIViewController {
    // Anh xa UI trong Main
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Che do an mat khau
        txtPassword.isSecureTextEntry = true
        
        // Tat tinh nang goi y do manh password
        txtPassword.passwordRules = nil
        txtPassword.textContentType = .none
        
        // Tat ban phim
        view.endEditing(true)
    }
    
    // Xu ly su kien khi an vao Register
    @IBAction func tapToRegister(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController")
        present(vc!, animated: true)
    }
    
    // Xu ly su kien khi an vao ProblemAccount
    @IBAction func tapToProblemAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProblemAccountViewController")
        present(vc!, animated: true)
    }
    
    // Xu ly su kien khi an vao nut dang nhap
    @IBAction func tapToLogin(_ sender: Any) {
        login()
    }
    
    // Ham xu ly login
    private func login() {
        // Kiem tra nil hoac whitespace cho username va password
        guard let username = txtUsername.text,
              !username.isEmpty,
              
              let password = txtPassword.text,
              !password.isEmpty else {
            self.view.makeToast("Không được phép để trống các ô nhập!", duration: 2.0, position: .top)
            return
        }
        
        // Goi loginAccount va checkRoleAccount trong AuthService, kiem tra username, password va quyen truy cap
        let db = AuthService()
        db.loginAccount(username: username, password: password, completion: { checkAuth in
            if checkAuth {
                db.checkRoleAccount(username: username, completion: { checkRole in
                    // Chuyen man hinh Admin khi checkRole = true, man hinh User khi checkRole = false
                    self.goInside(check: checkRole)
                })
            }
            else {
                self.view.makeToast("Sai Tài khoản hoặc Mật khẩu!", duration: 2.0, position: .top)
            }
        })
    }
    
    // Sau khi xac thuc thanh cong, chuyen qua man hinh tuy vao phan quyen nguoi dung
    private func goInside(check: Bool) {
        if check {
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainViewController")
            vc?.modalPresentationStyle = .fullScreen
            vc?.modalTransitionStyle = .crossDissolve
            present(vc!, animated: true)
        }
        else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "UserViewController")
            vc?.modalPresentationStyle = .fullScreen
            vc?.modalTransitionStyle = .crossDissolve
            present(vc!, animated: true)
        }
    }
}
