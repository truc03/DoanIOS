import UIKit

// MARK: - LichSuKhoViewController
class LichSuKhoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let refreshControl = UIRefreshControl()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Không có lịch sử nhập xuất kho"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var historyList: [History] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Lịch sử kho"
        setupTableView()
        setupUI()
        
        fetchHistory()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Pull to Refresh
        refreshControl.addTarget(self, action: #selector(refreshHistoryData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    @objc private func refreshHistoryData(_ sender: UIRefreshControl) {
        fetchHistory(isRefreshing: true)
    }

    func fetchHistory(isRefreshing: Bool = false) {
        if !isRefreshing {
            activityIndicator.startAnimating()
            emptyLabel.isHidden = true
        }

        FirebaseService.shared.fetchHistory { [weak self] documents, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()

                if let error = error {
                    print("Lỗi tải lịch sử:", error.localizedDescription)
                    self.showErrorAlert(message: error.localizedDescription)
                    return
                }

                self.historyList = documents ?? []

                self.emptyLabel.isHidden = !self.historyList.isEmpty
                self.tableView.reloadData()
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension LichSuKhoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }

        let historyItem = historyList[indexPath.row]
        cell.configure(with: historyItem)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LichSuKhoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

// MARK: - History Model
struct History: Identifiable, Codable {
    var id: String?
    
    var action: String
    var amount: Int
    var name: String
    var product_id: String
    var time: Date

    init(id: String? = nil, action: String, amount: Int, name: String, productId: String, time: Date) {
        self.id = id
        self.action = action
        self.amount = amount
        self.name = name
        self.product_id = productId
        self.time = time
    }
    
    // Helper properties để hiển thị
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: time)
    }
    
    var displayAmount: String {
        if action == "Nhập kho" {
            return "+\(amount)"
        } else {
            return "\(amount)"
        }
    }
}

// MARK: - HistoryCell
class HistoryCell: UITableViewCell {
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lblName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lblAction: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lblAmount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lblTime: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(lblName)
        cardView.addSubview(lblAction)
        cardView.addSubview(lblAmount)
        cardView.addSubview(lblTime)
        
        NSLayoutConstraint.activate([
            // cardView Constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // lblName Constraints
            lblName.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            lblName.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            lblName.trailingAnchor.constraint(equalTo: lblAmount.leadingAnchor, constant: -12),
            
            // lblAction Constraints
            lblAction.topAnchor.constraint(equalTo: lblName.bottomAnchor, constant: 8),
            lblAction.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            lblAction.widthAnchor.constraint(equalToConstant: 76),
            lblAction.heightAnchor.constraint(equalToConstant: 22),
            lblAction.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            // lblTime Constraints
            lblTime.centerYAnchor.constraint(equalTo: lblAction.centerYAnchor),
            lblTime.leadingAnchor.constraint(equalTo: lblAction.trailingAnchor, constant: 10),
            lblTime.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // lblAmount Constraints
            lblAmount.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            lblAmount.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            lblAmount.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    func configure(with history: History) {
        lblName.text = history.name
        lblTime.text = history.formattedDate
        
        if history.action == "Nhập kho" {
            lblAction.text = "Nhập kho"
            lblAction.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
            lblAction.textColor = .systemGreen
            lblAmount.text = history.displayAmount
            lblAmount.textColor = .systemGreen
        } else {
            lblAction.text = "Xuất kho"
            lblAction.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            lblAction.textColor = .systemRed
            lblAmount.text = history.displayAmount
            lblAmount.textColor = .systemRed
        }
    }
}
