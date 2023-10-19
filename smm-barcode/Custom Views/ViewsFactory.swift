//
//  ViewsFactory.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import TinyConstraints

class ViewsFactory {

    class func defaultImageView(image: UIImage? = nil, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        return imageView
    }

    class func defaultLabel(
        font: UIFont = .regular(17),
        textColor: UIColor = .appBlack,
        alignment: NSTextAlignment = .natural,
        lines: Int = 1,
        adjustFont: Bool = false
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.numberOfLines = lines
        if adjustFont {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
        }
        return label
    }

    class func defaultButton(
        type: UIButton.ButtonType = .system,
        color: UIColor = .appOrange,
        radius: CGFloat = 0,
        font: UIFont = .semibold(20),
        titleColor: UIColor = .appWhite,
        height: CGFloat? = nil
    ) -> UIButton {
        let button = UIButton(type: type)
        button.backgroundColor = color
        button.layer.cornerRadius = radius
        button.titleLabel?.font = font
        button.setTitleColor(titleColor, for: .normal)
        if let height = height {
            button.height(height)
        }
        return button
    }

    class func defaultStackView(
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        margins: TinyEdgeInsets? = nil
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = alignment
        if let margins = margins {
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = margins
        }
        return stackView
    }

    class func defaultBarButton(font: UIFont = .semibold(17), image: AppImage? = nil, color: UIColor = .appSystemBlue) -> UIBarButtonItem {
        let button = UIBarButtonItem()
        [.normal, .highlighted].forEach { button.setTitleTextAttributes([.font: font, .foregroundColor: color], for: $0) }
        let transparentColor = color.withAlphaComponent(0.2)
        button.setTitleTextAttributes([.font: font, .foregroundColor: transparentColor], for: .disabled)
        button.image = image?.uiImage
        button.tintColor = color
        return button
    }

    class func defaultActivityIndicator(style: UIActivityIndicatorView.Style = .medium, color: UIColor = .appSystemGray) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        return indicator
    }

    class func defaultScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        return scrollView
    }

    class func defaultTextField(
        color: UIColor = .appWhite,
        font: UIFont = .regular(17),
        padding: CGFloat = 16,
        height: CGFloat = 60
    ) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = color
        textField.font = font
        textField.setLeftViewPadding()
        textField.height(height)
        return textField
    }

    class func defaultToolbarView(width: CGFloat) -> UIToolbar {
        let height: CGFloat = 44
        let toolbarView = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        toolbarView.backgroundColor = .appLightGray
        toolbarView.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbarView.height(height)
        return toolbarView
    }

    class func defaultCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .appClear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }

    class func defaultTableView(style: UITableView.Style = .plain) -> UITableView {
        let tableView = UITableView(frame: .zero, style: style)
        tableView.backgroundColor = .appClear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.tableFooterView = UIView()
        return tableView
    }

    class func defaultSearchController(showCancelButton: Bool = false) -> UISearchController {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.setShowsCancelButton(showCancelButton, animated: false)
        return searchController
    }

    class func defaultHeaderView(text: String) -> UIView {
        let label = ViewsFactory.defaultLabel(font: .regular(13), textColor: .appSystemGray)
        label.text = text
        let headerView = UIView()
        headerView.addSubview(label)
        label.edgesToSuperview(insets: .horizontal(0) + .top(14) + .bottom(6))
        return headerView
    }

    // MARK: - Custom Views

    class func continueButton() -> UIButton {
        return defaultButton(radius: 14, height: Constants.isSmallScreen ? 50 : 56)
    }

    class func tosPrivacyButton() -> UIButton {
        return defaultButton(color: .appClear, font: .semibold(13), titleColor: .appSystemGray)
    }

    class func separatorLine(color: UIColor = .appSystemGray5, axis: NSLayoutConstraint.Axis = .vertical, thickness: CGFloat = 1) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        switch axis {
        case .vertical:
            line.width(thickness)
        case .horizontal:
            line.height(thickness)
        @unknown default:
            break
        }
        return line
    }

    class func premiumBarButton() -> UIBarButtonItem {
        return defaultBarButton(image: .commonCrown)
    }

    class func emptyLabel() -> UILabel {
        return defaultLabel(font: .regular(16), textColor: .appSystemGray4, alignment: .center, adjustFont: true)
    }

    class func wrapView(_ view: UIView) -> UIView {
        let wrapperView = UIView()
        wrapperView.backgroundColor = .appWhite
        wrapperView.layer.cornerRadius = 9
        wrapperView.clipsToBounds = true
        wrapperView.addSubview(view)
        view.edgesToSuperview()
        return wrapperView
    }

    class var filesCollectionViewInsets: TinyEdgeInsets {
        return .vertical(12)
    }

    class func filesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = filesCollectionViewInsets
        return collectionView
    }

}
