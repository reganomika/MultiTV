import UIKit
import SnapKit
import CustomNavigationView
import Utilities

class BaseController: UIViewController {
    
    lazy var topView: CustomNavigationView = {
        let view = CustomNavigationView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupView()
        setupConstraints()
    }
    
    func configurNavigation(
        leftView: UIView? = nil,
        centerView: UIView? = nil,
        rightView: UIView? = nil
    ) {
        topView.leftView = leftView
        topView.centerView = centerView
        topView.rightView = rightView
    }
    
    func setupView() {
        view.backgroundColor = .init(hex: "0B0C1E")
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(topView)
    }
    
    func setupConstraints() {
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}
