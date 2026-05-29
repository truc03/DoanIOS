//
//  TrangChuAdminViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by  User on 24.05.2026.
//

import UIKit

class TrangChuAdminViewController: UIViewController {
    private let totalProductsLabel = UILabel()
    private let greetingLabel = UILabel()
    private var isListeningStats = false
    private var didShowInitialLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDashboard()
        loadStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAuthButton()
        loadStats()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAuthButton()
        loadStats()

        if !UserDefaults.standard.bool(forKey: "isLoggedIn"), !didShowInitialLogin {
            didShowInitialLogin = true
            showLogin()
        }
    }

    @IBAction func NutNhapKho(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tableViewController = storyboard.instantiateViewController(withIdentifier: "TrangNhapkho") as? UIViewController {
                self.navigationController?.pushViewController(tableViewController, animated: true)
            }
    }
    
    @IBAction func NutXuatKho(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "TrangXuatKho") as? UIViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func NutLichSuKho(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tableViewController = storyboard.instantiateViewController(withIdentifier: "LichSuKho") as? UIViewController {
                self.navigationController?.pushViewController(tableViewController, animated: true)
            }    }
    private func setupDashboard() {
        title = "Quản lý kho"
        updateAuthButton()
    }

    private func loadStats() {
        let username = UserDefaults.standard.string(forKey: "currentUsername")
        greetingLabel.text = username.map { "Xin chào, \($0)" } ?? "Xin chào"
        guard !isListeningStats else { return }

        isListeningStats = true
        FirebaseService.shared.getHomeStats { [weak self] count in
            self?.totalProductsLabel.text = "\(count) sản phẩm đang quản lý"
        }
    }

    @objc private func showLogin() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "currentUsername")
            UserDefaults.standard.removeObject(forKey: "currentEmail")
            updateAuthButton()
            loadStats()
            showLogin()
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }

    private func updateAuthButton() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isLoggedIn ? "Đăng xuất" : "Đăng nhập",
            style: .plain,
            target: self,
            action: #selector(showLogin)
        )
    }

    @objc private func openImport() {
        NutNhapKho(UIButton(type: .system))
    }

    @objc private func openExport() {
        NutXuatKho(UIButton(type: .system))
    }

    @objc private func openHistory() {
        NutLichSuKho(UIButton(type: .system))
    }


}
