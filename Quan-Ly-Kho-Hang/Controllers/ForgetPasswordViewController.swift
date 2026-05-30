//
//  ForgetPasswordViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import OSLog

class ForgetPasswordViewController: UIViewController {
    // Anh xa cac UI trong Main
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtOTP: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //---------------------------------------------
    // Man hinh xac thuc OTP
    //---------------------------------------------
    
    // Xu ly su kien khi an vao ProblemAccount
    @IBAction func tapToProblemAccount(_ sender: Any) {
        dismiss(animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProblemAccountViewController")
        present(vc!, animated: true)
    }
    
    // Xu ly su kien khi an vao ForgetPassword
    @IBAction func tapToChangePassword(_ sender: Any) {
        // Kiem tra nil va whitespace cua email va OTP
        guard let email = txtEmail.text,
           !email.isEmpty,
           let otp = txtOTP.text,
           !otp.isEmpty else {
            return
        }
        
        // Truy xuat doi tuong AuthServices() va xu ly kiem tra OTP truoc khi gui chuyen qua man hinh thay doi mat khau
        let auth = AuthService()
        
        // Kiem tra trung khop va qua han thoi gian xac nhan cua OTP
        auth.checkOTP(email: email, otp: Int(otp)!, completion: { checkOTP in
            if checkOTP {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "RepasswordInForgetPasswordViewController")
                self.present(vc!, animated: true)
            }
            else {
                self.view.makeToast("Quá hạn hoặc không tồn tại Mã OTP!", duration: 2.0, position: .top)
            }
        })
    }
    
    // Xu ly su kien khi an vao nut gui OTP
    @IBAction func tapToGetOTP(_ sender: Any) {
        processOTP()
    }
    
    //---------------------------------------------
    // Man hinh thay doi mat khau
    //---------------------------------------------
    
    // Xu ly su kien tro ve man hinh quen mat khau
    @IBAction func tapToBackForgetPassword(_ sender: Any) {
        dismiss(animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordViewController")
        present(vc!, animated: true)
    }
    
    //---------------------------------------------
    // Cac ham xu ly logic
    //---------------------------------------------
    
    // Ham xu ly ma OTP
    private func processOTP() {
        // Kiem tra nil va whitespace cua email
        guard let email = txtEmail.text,
              !email.isEmpty else {
            self.view.makeToast("Không được để trống các ô!", duration: 2.0, position: .top)
            return
        }
        
        // Truy xuat doi tuong AuthServices() va xu ly ve check email, tao va gui ma OTP
        let auth = AuthService()
        
        // Kiem tra email ton tai
        auth.checkEmail(email: email, completion: { checkEmail in
            if checkEmail {
                // Tao ma OTP cho nguoi dung
                auth.createOTP(email: email, completion: { getCreateOTP in
                    if getCreateOTP > 0 {
                        // Gui ma OTP cho nguoi dung
                        auth.sendOTP(email: email, otp: getCreateOTP, completion: { checkSendOTP in
                            if checkSendOTP {
                                self.view.makeToast("Đã gửi mã OTP xác nhận!", duration: 2.0, position: .top)
                            }
                            else {
                                self.view.makeToast("Lỗi kỹ thuật không thể gửi mã OTP!", duration: 2.0, position: .top)
                            }
                        })
                    }
                    else {
                        self.view.makeToast("Lỗi kỹ thuật không thể gửi mã OTP!", duration: 2.0, position: .top)
                    }
                })
            }
            else {
                self.view.makeToast("Email không tồn tại!", duration: 2.0, position: .top)
            }
        })
    }
}
