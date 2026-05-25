import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private let productCol = "products"
    private let historyCol = "history"
    
    // MARK: - 1. DASHBOARD
    func getHomeStats(completion: @escaping (Int) -> Void) {
        db.collection(productCol).addSnapshotListener { snapshot, _ in
            let count = snapshot?.documents.count ?? 0
            completion(count)
        }
    }
    
    // MARK: - 2. FETCH PRODUCTS
    func fetchAllProducts(completion: @escaping ([Product]?, Error?) -> Void) {
        db.collection(productCol).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let products = snapshot?.documents.compactMap { doc -> Product? in
                var p = try? doc.data(as: Product.self)
                p?.id = doc.documentID
                return p
            }
            
            completion(products, nil)
        }
    }
    
    // MARK: - 3. ADD / UPDATE PRODUCT
    func saveProduct(_ product: Product, completion: @escaping (Error?) -> Void) {
        do {
            if let id = product.id {
                try db.collection(productCol).document(id).setData(from: product, completion: completion)
            } else {
                _ = try db.collection(productCol).addDocument(from: product, completion: completion)
            }
        } catch {
            completion(error)
        }
    }
    
    // MARK: - 4. DELETE PRODUCT
    func deleteProduct(id: String, completion: @escaping (Error?) -> Void) {
        db.collection(productCol).document(id).delete { error in
            completion(error)
        }
    }
    
    // MARK: - 5. NHẬP KHO (KHÔNG ĐỤNG STOCK)
    func importStock(productId: String,
                     name: String,
                     quantity: Int,
                     completion: @escaping (Error?) -> Void) {
        
        db.collection(historyCol).addDocument(data: [
            "action": "Nhập kho",
            "amount": quantity,
            "name": name,
            "product_id": productId,
            "time": Timestamp()
        ]) { error in
            completion(error)
        }
    }
    
    // MARK: - 6. XUẤT KHO (KHÔNG CHECK KHO)
    func exportStock(productId: String,
                     name: String,
                     quantity: Int,
                     completion: @escaping (Error?) -> Void) {
        
        db.collection(historyCol).addDocument(data: [
            "action": "Xuất kho",
            "amount": -quantity,
            "name": name,
            "product_id": productId,
            "time": Timestamp()
        ]) { error in
            completion(error)
        }
    }
    
    // MARK: - 7. LỊCH SỬ (ALL)
    func fetchHistory(completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
        db.collection(historyCol)
            .order(by: "time", descending: true)
            .getDocuments { snapshot, error in
                completion(snapshot?.documents, error)
            }
    }
    
    // MARK: - 8. LỊCH SỬ NHẬP
    func fetchImportHistory(completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
        db.collection(historyCol)
            .whereField("action", isEqualTo: "Nhập kho")
            .order(by: "time", descending: true)
            .getDocuments { snapshot, error in
                completion(snapshot?.documents, error)
            }
    }
    
    // MARK: - 9. LỊCH SỬ XUẤT
    func fetchExportHistory(completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
        db.collection(historyCol)
            .whereField("action", isEqualTo: "Xuất kho")
            .order(by: "time", descending: true)
            .getDocuments { snapshot, error in
                completion(snapshot?.documents, error)
            }
    }
}
