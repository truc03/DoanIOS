import SwiftUI

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Int
    var price: Double
}

struct ContentView: View {
    @State var products = [
        Product(name: "Dell Inspiron 15", quantity: 8, price: 15000000),
        Product(name: "iPhone 14 Pro", quantity: 12, price: 25000000)
    ]
    @State var showSheet = false

    var body: some View {
        NavigationView {
            List {
                // Hiển thị tổng tồn kho cho oai
                Text("Tổng tồn kho: \(products.reduce(0, {$0 + $1.quantity}))").bold()

                ForEach(products) { p in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(p.name).font(.headline)
                            Text("Giá: \(Int(p.price)) VNĐ - SL: \(p.quantity)")
                        }
                        Spacer()
                        // Nút Sửa
                        Button("Sửa") { showSheet = true }.foregroundColor(.orange)
                    }
                }
                .onDelete { i in products.remove(atOffsets: i) } // Chức năng Xóa
            }
            .navigationTitle("Quản Lý Kho")
            .navigationBarItems(trailing: Button("Thêm") { showSheet = true })
            .sheet(isPresented: $showSheet) { AddProduct() }
        }
    }
}
