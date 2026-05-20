//
//  LoginViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/18.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func tapToRegister(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController")
        present(vc!, animated: true)
    }
    
    @IBAction func tapToProblemAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProblemAccountViewController")
        present(vc!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
