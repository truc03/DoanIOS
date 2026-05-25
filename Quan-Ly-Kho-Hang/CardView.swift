import UIKit

class CardView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(title: String, value: String) {
        super.init(frame: .zero)

        setupView()
        setupData(title: title, value: value)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    // MARK: UI

    private func setupView() {

        backgroundColor = .white

        layer.cornerRadius = 16

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        translatesAutoresizingMaskIntoConstraints = false

        // TITLE

        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        titleLabel.numberOfLines = 2

        // VALUE

        valueLabel.font = UIFont.boldSystemFont(ofSize: 22)
        valueLabel.textColor = .black

        // STACK

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            valueLabel
        ])

        stack.axis = .vertical
        stack.spacing = 8

        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 16
            ),

            stack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),

            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),

            stack.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -16
            ),

            heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: DATA

    private func setupData(title: String, value: String) {

        titleLabel.text = title
        valueLabel.text = value
    }
}
