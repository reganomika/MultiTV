import UIKit
import SnapKit
import Utilities

final class TabBarController: UIViewController {

    private lazy var tabBarView: TabBarView = {
        let view = TabBarView()
        view.delegate = self
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 22
        return view
    }()
    
    private let viewControllers = [
        UINavigationController(rootViewController: AppsController()),
        UINavigationController(rootViewController: RemoteTVController()),
        UINavigationController(rootViewController: SettingsController())
    ]
    
    private var currentViewController: UIViewController?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        
        switchToViewController(viewControllers[1])
    }
    
    private func setupView() {
        view.addSubview(tabBarView)
    }

    private func setupConstraints() {
        
        tabBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(23)
            make.height.equalTo(92)
        }
    }

    private func switchToViewController(_ newViewController: UIViewController) {
        
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()

        addChild(newViewController)
        
        view.insertSubview(newViewController.view, belowSubview: tabBarView)
        
        newViewController.view.frame = view.bounds
        newViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newViewController.didMove(toParent: self)

        currentViewController = newViewController
    }
}

extension TabBarController: TabBarViewDelegate {
    
    func tabBarView(_ tabBarView: TabBarView, didSelectItemAt index: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let selectedViewController = viewControllers[index]
        switchToViewController(selectedViewController)
    }
}
