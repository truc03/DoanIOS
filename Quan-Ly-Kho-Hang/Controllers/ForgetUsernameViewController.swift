//
//  ForgetUsernameViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit
import OSLog

class ForgetUsernameViewController: UIViewController {
    // Anh xa UI trong Main
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Xu ly su kien khi an vao ProblemAccount
    @IBAction func tapToProblemAccount(_ sender: Any) {
        dismiss(animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProblemAccountViewController")
        present(vc!, animated: true)
    }
    
    // Xu ly su kien khi an vao nut Xac nhan
    @IBAction func tapToProcess(_ sender: Any) {
        process()
    }
    
    // Ham xu ly quen tai khoan
    private func process() {
        guard let email = txtEmail.text,
              !email.isEmpty else {
            self.view.makeToast("Không được để trống các ô!", duration: 2.0, position: .top)
            return
        }
        
        let auth = AuthService()
        auth.checkEmail(email: email, completion: { check in
            if check {
                auth.sendEmail(email: email)
                self.view.makeToast("Đã gửi email xác nhận!", duration: 2.0, position: .top)
            }
            else {
                self.view.makeToast("Email không tồn tại!", duration: 2.0, position: .top)
            }
        })
        
        auth.clickedEmail(email: email, completion: { check in
            if check {
                
            }
            else {
                
            }
            os_log("\(check)")
        })
    }
}
