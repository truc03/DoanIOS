//
//  RegisterViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Toast
import OSLog

class RegisterViewController: UIViewController {
    // Anh xa cac UI trong Main
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Che do an mat khau
        txtPassword.isSecureTextEntry = true
        txtRePassword.isSecureTextEntry = true
        
        // Tat tinh nang goi y do manh password
        txtPassword.passwordRules = nil
        txtPassword.textContentType = .none
        txtRePassword.passwordRules = nil
        txtRePassword.textContentType = .none
        
        // Tat ban phim
        view.endEditing(true)
    }
    
    // Chuyen ve man hinh Login
    @IBAction func tapToLogin(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Xu ly su kien khi an vao nut Register
    @IBAction func tapToRegister(_ sender: Any) {
        createAccount()
    }
    
    // Ham xu ly tao nguoi dung moi
    private func createAccount() {
        // Kiem tra gia tri nhap vao khong phai nil va whitespace
        guard let username = txtUsername.text,
                !username.isEmpty,
              
                let email = txtEmail.text,
                !email.isEmpty,
              
                let password = txtPassword.text,
                !password.isEmpty,
              
                let repassword = txtRePassword.text,
                !repassword.isEmpty
        else {
            self.view.makeToast("Không được phép để trống các ô nhập!", duration: 2.0, position: .top)
            return
        }
        
        // Kiem tra lai mat khau lan 2
        if password == repassword {
            // Goi createAccountService trong lop AuthServices, thuc thi va kiem tra thanh cong
            let auth = AuthService()
            auth.createAccountService(username: username, email: email, password: password, completion: { check in
                if check {
                    self.view.makeToast("Đăng ký thành công!", duration: 2.0, position: .top)
                    
                    // Gia han them 1s de hien thi thong bao thanh cong, sau do chuyen sang man hinh Login
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.dismiss(animated: true)
                    })
                }
                else {
                    self.view.makeToast("Đăng ký thất bại!", duration: 2.0, position: .top)
                }
            })
        }
        else {
            self.view.makeToast("Mật khẩu không trùng khớp!", duration: 2.0, position: .top)
        }
    }
}
