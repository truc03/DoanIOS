//
//  NhapKhoViewController.swift
//  Quan-Ly-Kho-Hang
//
//  Created by  User on 24.05.2026.
//

import UIKit

class NhapKhoViewController: StockTransactionViewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mode = .importStock
    }
}

class XuatKhoViewController: StockTransactionViewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mode = .exportStock
    }
}

class StockTransactionViewController: UIViewController {
    enum Mode {
        case importStock
        case exportStock

        var title: String {
            switch self {
            case .importStock:
                return "Nhập kho"
            case .exportStock:
                return "Xuất kho"
            }
        }

        var buttonTitle: String {
            switch self {
            case .importStock:
                return "Xác nhận nhập"
            case .exportStock:
                return "Xác nhận xuất"
            }
        }

        var tintColor: UIColor {
            switch self {
            case .importStock:
                return .systemGreen
            case .exportStock:
                return .systemOrange
            }
        }
    }

    var mode: Mode = .importStock

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let productNameField = UITextField()
    private let quantityField = UITextField()
    private let actionButton = UIButton(type: .system)
    private let emptyLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var products: [Product] = []
    private var selectedProduct: Product?

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProducts()
    }

    private func setupUI() {
        title = mode.title
        view.backgroundColor = .systemGroupedBackground
        view.subviews.forEach { $0.removeFromSuperview() }

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        productNameField.placeholder = "Tên sản phẩm"
        productNameField.borderStyle = .roundedRect
        productNameField.clearButtonMode = .whileEditing
        productNameField.autocapitalizationType = .words
        productNameField.returnKeyType = .next
        productNameField.delegate = self

        quantityField.placeholder = "Số lượng"
        quantityField.borderStyle = .roundedRect
        quantityField.keyboardType = .numberPad

        actionButton.setTitle(mode.buttonTitle, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        actionButton.backgroundColor = mode.tintColor
        actionButton.layer.cornerRadius = 8
        actionButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        actionButton.addTarget(self, action: #selector(submitTransaction), for: .touchUpInside)

        let hintLabel = UILabel()
        hintLabel.text = mode == .importStock
            ? "Chọn sản phẩm có sẵn hoặc nhập tên mới để tạo sản phẩm."
            : "Chọn sản phẩm bên dưới rồi nhập số lượng cần xuất."
        hintLabel.font = .systemFont(ofSize: 13)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        headerStack.addArrangedSubview(productNameField)
        headerStack.addArrangedSubview(quantityField)
        headerStack.addArrangedSubview(actionButton)
        headerStack.addArrangedSubview(hintLabel)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = "Chưa có sản phẩm trong kho"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerStack)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchProducts() {
        activityIndicator.startAnimating()
        FirebaseService.shared.fetchAllProducts { [weak self] products, error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showAlert(title: "Lỗi", message: error.localizedDescription)
                return
            }

            self.products = products ?? []
            self.emptyLabel.isHidden = !self.products.isEmpty
            self.tableView.reloadData()
        }
    }

    @objc private func submitTransaction() {
        view.endEditing(true)

        let name = productNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            showAlert(title: "Thiếu thông tin", message: "Vui lòng nhập hoặc chọn tên sản phẩm.")
            return
        }

        guard let quantityText = quantityField.text,
              let quantity = Int(quantityText),
              quantity > 0 else {
            showAlert(title: "Thiếu thông tin", message: "Số lượng phải là số lớn hơn 0.")
            return
        }

        actionButton.isEnabled = false
        actionButton.alpha = 0.7

        let completion: (Error?) -> Void = { [weak self] error in
            guard let self = self else { return }
            self.actionButton.isEnabled = true
            self.actionButton.alpha = 1

            if let error = error {
                self.showAlert(title: "Lỗi", message: error.localizedDescription)
                return
            }

            self.quantityField.text = ""
            self.selectedProduct = nil
            self.productNameField.text = ""
            self.showAlert(title: "Thành công", message: "\(self.mode.title) thành công.")
            self.fetchProducts()
        }

        switch mode {
        case .importStock:
            saveImport(name: name, quantity: quantity, completion: completion)
        case .exportStock:
            guard let product = selectedProduct, let id = product.id else {
                showAlert(title: "Chọn sản phẩm", message: "Vui lòng chọn sản phẩm cần xuất trong danh sách.")
                actionButton.isEnabled = true
                actionButton.alpha = 1
                return
            }
            FirebaseService.shared.exportStock(productId: id, quantity: quantity, completion: completion)
        }
    }

    private func saveImport(name: String, quantity: Int, completion: @escaping (Error?) -> Void) {
        if let product = selectedProduct, let id = product.id {
            FirebaseService.shared.importStock(productId: id, quantity: quantity, completion: completion)
            return
        }

        if let matchingProduct = products.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }),
           let id = matchingProduct.id {
            FirebaseService.shared.importStock(productId: id, quantity: quantity, completion: completion)
            return
        }

        FirebaseService.shared.saveProduct(Product(id: nil, name: name, quantity: quantity)) { error in
            completion(error)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension StockTransactionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProductCell")
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = "Tồn: \(product.quantity)"
        cell.accessoryType = product.id == selectedProduct?.id ? .checkmark : .none
        cell.tintColor = mode.tintColor

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = product.name
            content.secondaryText = "Tồn: \(product.quantity)"
            content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
            content.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = content
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProduct = products[indexPath.row]
        productNameField.text = selectedProduct?.name
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard mode == .importStock else {
            return nil
        }

        let product = products[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            self?.confirmDelete(product)
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Sửa") { [weak self] _, _, completion in
            self?.showEditProduct(product)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    private func showEditProduct(_ product: Product) {
        let alert = UIAlertController(title: "Sửa sản phẩm", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Tên sản phẩm"
            textField.text = product.name
            textField.autocapitalizationType = .words
        }
        alert.addTextField { textField in
            textField.placeholder = "Số lượng tồn"
            textField.text = "\(product.quantity)"
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let quantityText = alert?.textFields?.last?.text ?? ""

            guard !name.isEmpty else {
                self.showAlert(title: "Thiếu thông tin", message: "Tên sản phẩm không được để trống.")
                return
            }

            guard let quantity = Int(quantityText), quantity >= 0 else {
                self.showAlert(title: "Sai số lượng", message: "Số lượng tồn phải là số không âm.")
                return
            }

            FirebaseService.shared.saveProduct(Product(id: product.id, name: name, quantity: quantity)) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Lỗi", message: error.localizedDescription)
                    return
                }

                self?.selectedProduct = nil
                self?.productNameField.text = ""
                self?.fetchProducts()
            }
        })

        present(alert, animated: true)
    }

    private func confirmDelete(_ product: Product) {
        let alert = UIAlertController(
            title: "Xóa sản phẩm",
            message: "Bạn có chắc muốn xóa \(product.name) khỏi kho?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            guard let id = product.id else { return }
            FirebaseService.shared.deleteProduct(id: id) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Lỗi", message: error.localizedDescription)
                    return
                }

                self?.selectedProduct = nil
                self?.productNameField.text = ""
                self?.fetchProducts()
            }
        })

        present(alert, animated: true)
    }
}

extension StockTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == productNameField {
            quantityField.becomeFirstResponder()
        }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == productNameField {
            selectedProduct = nil
            tableView.reloadData()
        }
    }
}
