import Foundation

enum StockAction: String, Codable {
    case importStock = "Nhập kho"
    case exportStock = "Xuất kho"
}

final class FirebaseService {
    static let shared = FirebaseService()

    private let productsKey = "local_products"
    private let historyKey = "local_history"
    private let usersKey = "local_users"
    private let queue = DispatchQueue(label: "QuanLyKhoHang.LocalStore")

    private init() {}

    func getHomeStats(completion: @escaping (Int) -> Void) {
        queue.async {
            let count = self.loadProducts().count
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }

    func fetchAllProducts(completion: @escaping ([Product]?, Error?) -> Void) {
        queue.async {
            let products = self.loadProducts().sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            DispatchQueue.main.async {
                completion(products, nil)
            }
        }
    }

    func listenProducts(completion: @escaping ([Product]?, Error?) -> Void) {
        fetchAllProducts(completion: completion)
    }

    func saveProduct(_ product: Product, completion: @escaping (Error?) -> Void) {
        queue.async {
            let name = product.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else {
                self.complete(completion, errorMessage: "Tên sản phẩm không được để trống")
                return
            }

            guard product.quantity >= 0 else {
                self.complete(completion, errorMessage: "Số lượng không hợp lệ")
                return
            }

            var products = self.loadProducts()
            var savedProduct = Product(id: product.id ?? UUID().uuidString, name: name, quantity: product.quantity)

            if let index = products.firstIndex(where: { $0.id == savedProduct.id }) {
                products[index] = savedProduct
            } else if let index = products.firstIndex(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                savedProduct.id = products[index].id
                products[index] = savedProduct
            } else {
                products.append(savedProduct)
                if savedProduct.quantity > 0, let productId = savedProduct.id {
                    var history = self.loadHistory()
                    history.append(History(
                        id: UUID().uuidString,
                        action: StockAction.importStock.rawValue,
                        amount: savedProduct.quantity,
                        name: savedProduct.name,
                        productId: productId,
                        time: Date()
                    ))
                    self.saveHistory(history)
                }
            }

            self.saveProducts(products)
            self.complete(completion)
        }
    }

    func deleteProduct(id: String, completion: @escaping (Error?) -> Void) {
        queue.async {
            let products = self.loadProducts().filter { $0.id != id }
            self.saveProducts(products)
            self.complete(completion)
        }
    }

    func importStock(productId: String, quantity: Int, completion: @escaping (Error?) -> Void) {
        updateStock(productId: productId, quantity: quantity, action: .importStock, completion: completion)
    }

    func exportStock(productId: String, quantity: Int, completion: @escaping (Error?) -> Void) {
        updateStock(productId: productId, quantity: quantity, action: .exportStock, completion: completion)
    }

    func fetchHistory(completion: @escaping ([History]?, Error?) -> Void) {
        queue.async {
            let history = self.loadHistory().sorted { $0.time > $1.time }
            DispatchQueue.main.async {
                completion(history, nil)
            }
        }
    }

    func fetchImportHistory(completion: @escaping ([History]?, Error?) -> Void) {
        fetchFilteredHistory(action: .importStock, completion: completion)
    }

    func fetchExportHistory(completion: @escaping ([History]?, Error?) -> Void) {
        fetchFilteredHistory(action: .exportStock, completion: completion)
    }

    func registerUser(username: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        queue.async {
            let userName = username.trimmingCharacters(in: .whitespacesAndNewlines)
            let userEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            guard !userName.isEmpty, !userEmail.isEmpty, !password.isEmpty else {
                self.complete(completion, errorMessage: "Các trường không được để trống")
                return
            }

            var users = self.loadUsers()

            if users.contains(where: { $0.username.caseInsensitiveCompare(userName) == .orderedSame }) {
                self.complete(completion, errorMessage: "Tên tài khoản đã tồn tại")
                return
            }

            if users.contains(where: { $0.email.caseInsensitiveCompare(userEmail) == .orderedSame }) {
                self.complete(completion, errorMessage: "Email đã được sử dụng")
                return
            }

            users.append(LocalUser(username: userName, email: userEmail, password: password))
            self.saveUsers(users)
            self.complete(completion)
        }
    }

    func loginUser(username: String, password: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        queue.async {
            let userName = username.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !userName.isEmpty, !password.isEmpty else {
                let error = self.makeError("Tài khoản và mật khẩu không được rỗng")
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
                return
            }

            let user = self.loadUsers().first {
                $0.username.caseInsensitiveCompare(userName) == .orderedSame && $0.password == password
            }

            DispatchQueue.main.async {
                if let user = user {
                    completion(true, user.email, nil)
                } else {
                    completion(false, nil, self.makeError("Sai tài khoản hoặc mật khẩu"))
                }
            }
        }
    }

    func forgetUsername(email: String, completion: @escaping (String?, Error?) -> Void) {
        queue.async {
            let userEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let user = self.loadUsers().first { $0.email.caseInsensitiveCompare(userEmail) == .orderedSame }

            DispatchQueue.main.async {
                if let user = user {
                    completion(user.username, nil)
                } else {
                    completion(nil, self.makeError("Không tìm thấy tài khoản liên kết với email này"))
                }
            }
        }
    }

    func forgetPassword(email: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        queue.async {
            let userEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !userEmail.isEmpty, !newPassword.isEmpty else {
                self.complete(completion, errorMessage: "Các thông tin không được để trống")
                return
            }

            var users = self.loadUsers()
            guard let index = users.firstIndex(where: { $0.email.caseInsensitiveCompare(userEmail) == .orderedSame }) else {
                self.complete(completion, errorMessage: "Không tìm thấy tài khoản liên kết với email này")
                return
            }

            users[index].password = newPassword
            self.saveUsers(users)
            self.complete(completion)
        }
    }

    private func updateStock(productId: String, quantity: Int, action: StockAction, completion: @escaping (Error?) -> Void) {
        queue.async {
            guard quantity > 0 else {
                let message = action == .importStock ? "Số lượng nhập phải lớn hơn 0" : "Số lượng xuất phải lớn hơn 0"
                self.complete(completion, errorMessage: message)
                return
            }

            var products = self.loadProducts()
            guard let index = products.firstIndex(where: { $0.id == productId }) else {
                self.complete(completion, errorMessage: "Không tìm thấy sản phẩm")
                return
            }

            if action == .exportStock, products[index].quantity < quantity {
                self.complete(completion, errorMessage: "Không đủ hàng trong kho")
                return
            }

            let amount = action == .importStock ? quantity : -quantity
            products[index].quantity += amount
            self.saveProducts(products)

            var history = self.loadHistory()
            history.append(History(
                id: UUID().uuidString,
                action: action.rawValue,
                amount: amount,
                name: products[index].name,
                productId: productId,
                time: Date()
            ))
            self.saveHistory(history)
            self.complete(completion)
        }
    }

    private func fetchFilteredHistory(action: StockAction, completion: @escaping ([History]?, Error?) -> Void) {
        queue.async {
            let history = self.loadHistory()
                .filter { $0.action == action.rawValue }
                .sorted { $0.time > $1.time }
            DispatchQueue.main.async {
                completion(history, nil)
            }
        }
    }

    private func loadProducts() -> [Product] {
        load([Product].self, forKey: productsKey) ?? []
    }

    private func saveProducts(_ products: [Product]) {
        save(products, forKey: productsKey)
    }

    private func loadHistory() -> [History] {
        load([History].self, forKey: historyKey) ?? []
    }

    private func saveHistory(_ history: [History]) {
        save(history, forKey: historyKey)
    }

    private func loadUsers() -> [LocalUser] {
        load([LocalUser].self, forKey: usersKey) ?? []
    }

    private func saveUsers(_ users: [LocalUser]) {
        save(users, forKey: usersKey)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }

    private func complete(_ completion: @escaping (Error?) -> Void, errorMessage: String? = nil) {
        let error = errorMessage.map(makeError)
        DispatchQueue.main.async {
            completion(error)
        }
    }

    private func makeError(_ message: String) -> NSError {
        NSError(domain: "QuanLyKhoHang.LocalStore", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

private struct LocalUser: Codable {
    var username: String
    var email: String
    var password: String
}
