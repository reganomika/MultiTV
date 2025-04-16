import UIKit
import SnapKit
import Utilities

final class FAQController: BaseController {
    
    private let viewModel = FAQViewModel()
    
    private var extendedIndexes: [Int] = []
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FAQ".localized
        label.font = .font(weight: .bold, size: 25)
        return label
    }()
    
    private lazy var topButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(FAQCell.self, forCellReuseIdentifier: FAQCell.identifier)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurNavigation(
            leftView: topButton,
            centerView: titleLabel
        )
        
        setupUI()
    }
    
    func setupUI() {
        
        view.addSubviews(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc private func close() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        pop()
    }
}

extension FAQController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FAQCell.identifier) as? FAQCell else {
            fatalError("Could not dequeue FAQCell")
        }
        cell.configure(
            model: viewModel.models[indexPath.row],
            isExpanded: extendedIndexes.contains(indexPath.row),
            isSeparatorHidden: viewModel.models.count - 1 == indexPath.row
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if extendedIndexes.contains(indexPath.row) {
            extendedIndexes.removeAll { $0 == indexPath.row }
        } else {
            extendedIndexes.append(indexPath.row)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

