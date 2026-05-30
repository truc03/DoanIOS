//
//  ViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit

class MainViewController: UIViewController {
    // Anh xa cac UI trong Main
    @IBOutlet weak var btnAdmin: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Xu ly su kien quay ve trang dang nhap
    @IBAction func tapToGoBackLogin(_ sender: Any) {
        dismiss(animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        present(vc!, animated: true)
    }
    
    // Xu ly su kien khi nhan vao nut Admin
    @IBAction func goToAdmin(_ sender: Any) {
        
    }
    
    // Xu ly su kien khi nhan vao nut User
    @IBAction func goToUser(_ sender: Any) {
        
    }
}

