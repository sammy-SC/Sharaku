import UIKit

extension UIView {
    func add(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    func add(views: [UIView]) {
        views.forEach{ add(view: $0) }
    }
}

extension UIViewController {
    func removeFromContainer() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    func add(to viewController: UIViewController, container: UIView) {
        viewController.addChild(self)
        container.add(view: view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.leftAnchor.constraint(equalTo: container.leftAnchor),
            view.rightAnchor.constraint(equalTo: container.rightAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
}

public final class ContainerViewController: UIViewController {
    public var didFinishWithImage: (UIImage) -> Void = { _ in }
    public var didCancel: () -> Void = {  }
    private let filterViewController: SHViewController
    private let cropViewController: CropViewController
    private let containerView = UIView()
    private let filter: UIButton = {
       let b = UIButton()
        b.setTitleColor(.gray, for: UIControl.State.normal)
        b.setTitleColor(.black, for: UIControl.State.selected)
        b.setTitle("Filter", for: UIControl.State.normal)
        return b
    }()
    private let crop: UIButton = {
        let b = UIButton()
        b.setTitleColor(.gray, for: UIControl.State.normal)
        b.setTitleColor(.black, for: UIControl.State.selected)
        b.setTitle("Crop", for: UIControl.State.normal)
        return b
    }()

    public init(image: UIImage) {
        filterViewController = SHViewController(image: image)
        cropViewController = CropViewController(image: image)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    override public func loadView() {
        super.loadView()

        let topBar = UIView()
        topBar.backgroundColor = .white
        view.add(view: topBar)

        let next = UIButton()
        next.setTitleColor(.black, for: UIControl.State.normal)
        next.setTitle("Next", for: UIControl.State.normal)
        next.addTarget(self, action: #selector(ContainerViewController.didTapNext), for: UIControl.Event.touchUpInside)

        let back = UIButton()
        back.setTitleColor(.black, for: UIControl.State.normal)
        back.setTitle("Back", for: UIControl.State.normal)
        back.addTarget(self, action: #selector(ContainerViewController.didTapBack), for: UIControl.Event.touchUpInside)

        topBar.add(views: [next, back])

        NSLayoutConstraint.activate([
            topBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            topBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.bottomAnchor.constraint(equalTo: view.safeTop, constant: 44),

            next.rightAnchor.constraint(equalTo: topBar.rightAnchor, constant: -10),
            next.heightAnchor.constraint(equalToConstant: 44),
            next.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),

            back.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 10),
            back.heightAnchor.constraint(equalToConstant: 44),
            back.bottomAnchor.constraint(equalTo: topBar.bottomAnchor)
        ])

        let bottomTab = UIView()
        bottomTab.backgroundColor = .white
        view.add(view: bottomTab)

        bottomTab.add(views: [filter, crop])

        NSLayoutConstraint.activate([
            bottomTab.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomTab.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomTab.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomTab.topAnchor.constraint(equalTo: view.safeBottom, constant: -44),

            filter.leftAnchor.constraint(equalTo: bottomTab.leftAnchor),
            filter.heightAnchor.constraint(equalToConstant: 44),
            filter.topAnchor.constraint(equalTo: bottomTab.topAnchor),
            filter.rightAnchor.constraint(equalTo: bottomTab.centerXAnchor),

            crop.leftAnchor.constraint(equalTo: bottomTab.centerXAnchor),
            crop.heightAnchor.constraint(equalToConstant: 44),
            crop.topAnchor.constraint(equalTo: bottomTab.topAnchor),
            crop.rightAnchor.constraint(equalTo: bottomTab.rightAnchor),
        ])

        view.add(view: containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomTab.topAnchor),
        ])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        showFilter()
        filter.addTarget(self, action: #selector(ContainerViewController.showFilter), for: UIControl.Event.touchUpInside)
        crop.addTarget(self, action: #selector(ContainerViewController.showCrop), for: UIControl.Event.touchUpInside)
    }

    @objc func showFilter() {
        if let image = cropViewController.croppedImage {
            filterViewController.image = image
        }
        cropViewController.removeFromContainer()
        filterViewController.add(to: self, container: containerView)
        filter.isSelected = true
        crop.isSelected = false
    }

    @objc func showCrop() {
        filterViewController.removeFromContainer()
        cropViewController.add(to: self, container: containerView)
        filter.isSelected = false
        crop.isSelected = true
    }

    @objc func didTapNext() {
        func sendImageFromFilter() {
            guard let image = filterViewController.imageView?.image else {
                assertionFailure()
                return
            }
            didFinishWithImage(image)
        }
        if cropViewController.parent == nil {
            sendImageFromFilter()
        } else {
            filterViewController.image = cropViewController.croppedImage
            sendImageFromFilter()
        }
        dismiss(animated: true, completion: nil)
    }

    @objc func didTapBack() {
        didCancel()
    }
}
