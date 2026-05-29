//
//  LichSuNhapXuatKhoViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by  User on 25.05.2026.
//

import UIKit

class LichSuNhapXuatKhoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func NutLichNhapXuatKho(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let lichSuVC = storyboard.instantiateViewController(withIdentifier: "LichSuNhapXuatKho") as? LichSuNhapXuatKhoViewController {
            navigationController?.pushViewController(lichSuVC, animated: true)
        }
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
