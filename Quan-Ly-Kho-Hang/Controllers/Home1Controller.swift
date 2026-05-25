import UIKit

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        
        setupUI()
    }
    
    func setupUI() {
        
        // MARK: HEADER
        let titleLabel = UILabel()
        titleLabel.text = "Tổng quan"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        
        let dateLabel = UILabel()
        dateLabel.text = "Hôm nay • 11/05/2026"
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        
        // MARK: CARDS
        let card1 = CardView(title: "Tổng sản phẩm", value: "4,586")
        let card2 = CardView(title: "Sắp hết hàng", value: "12")
        let card3 = CardView(title: "Nhập hôm nay", value: "38")
        let card4 = CardView(title: "Xuất hôm nay", value: "21")
        
        let row1 = UIStackView(arrangedSubviews: [card1, card2])
        let row2 = UIStackView(arrangedSubviews: [card3, card4])
        
        [row1, row2].forEach {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.distribution = .fillEqually
        }
        
        let grid = UIStackView(arrangedSubviews: [row1, row2])
        grid.axis = .vertical
        grid.spacing = 12
        
        // MARK: QUICK ACTION
        let btn1 = createButton(title: "Nhập kho")
        let btn2 = createButton(title: "Xuất kho")
        let btn3 = createButton(title: "Sản phẩm")
        
        let quickStack = UIStackView(arrangedSubviews: [btn1, btn2, btn3])
        quickStack.axis = .horizontal
        quickStack.spacing = 12
        quickStack.distribution = .fillEqually
        
        // MARK: MAIN STACK
        let mainStack = UIStackView(arrangedSubviews: [
            headerStack,
            grid,
            quickStack
        ])
        
        mainStack.axis = .vertical
        mainStack.spacing = 20
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        quickStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    // MARK: BUTTON
    func createButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        return btn
    }
}
