import SwiftUI
import FirebaseFirestore

struct AddProduct : View {
    @State var txtName = ""
    @State var txtQty = ""
    @State var txtPrice = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                TextField("Tên sản phẩm", text: $txtName)
                TextField("Số lượng", text: $txtQty).keyboardType(.numberPad)
                TextField("Giá", text: $txtPrice).keyboardType(.numberPad)

                Button("LƯU VÀO DATABASE") {
                    // goi db
                    let db = Firestore.firestore()
                    let data: [String: Any] = [
                        "name": txtName,
                        "brand": "Dell",
                        "category": "Laptop",
                        "price": Int(txtPrice) ?? 0,
                        "quantity": Int(txtQty) ?? 0,
                        "product_code": "DELL123",
                        "min_stock": 5
                    ]

                    // Lệnh thêm mới vào collection "products"
                    db.collection("products").addDocument(data: data) { error in
                        if let error = error {
                            print("Lỗi khi lưu: \(error.localizedDescription)")
                        } else {
                            print("Trực ơi, lưu thành công rồi!")
                            dismiss() // Đóng màn hình để quay về danh sách
                        }
                    }
                    print("Đã lưu: \(txtName)")
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Chi tiết hàng hóa")
        }
    }
}
