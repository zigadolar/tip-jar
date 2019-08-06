//
//  TipJarViewController.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import UIKit
import StoreKit

public protocol TipJarViewControllerDelegate: AnyObject {
    func tipJarViewControllerWillDismiss(_ controller: UIViewController)
    func tipJarViewControllerDidDismiss(_ controller: UIViewController)
}

public final class TipJarViewController: UIViewController {

    public struct Model {
        public let products: [String: String]

        public var topText: String?
        public var bottomText: String?

        public init(products: [String: String], topText: String? = nil, bottomText: String? = nil) {
            self.topText = topText
            self.bottomText = bottomText

            self.products = products
        }
    }

    private var model: Model!

    private lazy var storeManager: StoreManager = {
        StoreManager.productIdentifiers = Array(model.products.keys)

        return .shared
    }()

    private lazy var persistenceManager: TipPersistenceManager = .shared

    @IBOutlet private var containerView: UIView!

    // MARK: - Loading views
    @IBOutlet private var loadingView: UIView!
    @IBOutlet private var loadingLabel: UILabel!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!

    // MARK: - Store views
    @IBOutlet private var storeView: UIStackView!
    @IBOutlet private var topLabel: UILabel!
    @IBOutlet private var bottomLabel: UILabel!
    @IBOutlet private var totalTipsLabel: UILabel!
    @IBOutlet private var tipViewsStackView: UIStackView!

    // MARK: - Thank You views
    @IBOutlet private var thankYouView: UIStackView!
    @IBOutlet private var thankYouEmojiLabel: UILabel!
    @IBOutlet private var thankYouLabel: UILabel!
    @IBOutlet private var thankYouTotalLabel: UILabel!

    @IBOutlet private var closeButton: UIButton!

    @IBOutlet private var standaloneConstraints: [NSLayoutConstraint]!
    @IBOutlet private var nonStandaloneConstraints: [NSLayoutConstraint]!

    public var standalone: Bool = false
    public weak var delegate: TipJarViewControllerDelegate?
    public var textColor: UIColor? {
        didSet {
            guard let color = textColor else {
                return
            }

            updateTextColor(with: color)
        }
    }

    public func configure(with model: Model)
    {
        self.model = model
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        closeButton.isHidden = true

        containerView.roundCorners(20)
        configureView()

        guard let color = textColor else {
            return
        }

        updateTextColor(with: color)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchStuff()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if standalone {
            closeButton.alpha = 0
            closeButton.isHidden = false

            UIView.animate(withDuration: 0.25) {
                self.closeButton.alpha = 1
            }
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return standalone ? .lightContent : .default
    }

    private func fetchStuff() {
        storeManager.fetchProducts { [weak self] products in
            guard let self = self else { return }

            self.configureView(with: products.sorted(by: { $0.price.doubleValue < $1.price.doubleValue }))
        }
    }

    private func configureView() {
        loadingLabel.text = "Connecting to store..."

        let topText = model.topText ?? ""
        topLabel.text = topText
        topLabel.isHidden = !(topText.count > 0)

        let bottomText = model.bottomText ?? ""
        bottomLabel.text = bottomText
        bottomLabel.isHidden = !(bottomText.count > 0)

        let totalTipsString = persistenceManager.totalTipsAmount
        totalTipsLabel.text = "You have tipped \(totalTipsString) so far! 🤩"
        totalTipsLabel.isHidden = totalTipsString.isEmpty

        if standalone {
            view.backgroundColor = .clear
        } else {
            containerView.backgroundColor = .clear
        }

        NSLayoutConstraint.activate(standalone ? standaloneConstraints : nonStandaloneConstraints)
        NSLayoutConstraint.deactivate(standalone ? nonStandaloneConstraints : standaloneConstraints)

        storeView.isHidden = true
        thankYouView.isHidden = true
    }

    @IBAction private func didTapButton(_ sender: UIButton) {
        delegate?.tipJarViewControllerWillDismiss(self)

        UIView.animate(withDuration: 0.25) {
            self.closeButton.isHidden = true
        }

        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            self.delegate?.tipJarViewControllerDidDismiss(self)
        }
    }

    // MARK: - Private

    private func configureView(with products: [SKProduct]) {
        guard !products.isEmpty else {
            connectingToStoreFailed()
            return
        }

        products.forEach { product in
            let previousView = tipViewsStackView.arrangedSubviews.last as? TipView

            let view = TipView()
            view.configure(with: product, emoji: model.products[product.productIdentifier])
            view.delegate = self
            tipViewsStackView.addArrangedSubview(view)

            if let color = textColor {
                view.descriptionLabel.textColor = color
            }

            if let lastView = previousView {
                lastView.purchaseButton.widthAnchor.constraint(equalTo: view.purchaseButton.widthAnchor).isActive = true
            }
        }

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.loadingView.alpha = 0
            }) { _ in
                UIView.animate(withDuration: 0.25) {
                    self.loadingView.isHidden = true
                    self.storeView.isHidden = false
                }
            }
        }
    }

    private func configureThankYouView(with product: SKProduct) {
        let emoji = model.products[product.productIdentifier]

        thankYouEmojiLabel.text = emoji
        thankYouEmojiLabel.isHidden = emoji == nil

        let formatter: NumberFormatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        var priceString = ""
        if let price = formatter.string(from: product.price) {
            priceString = "\(price) "
        }

        thankYouLabel.text = "Thank you for the \(priceString)tip! Your generocity is greatly appreciated!"

        let totalTipsString = persistenceManager.totalTipsAmount
        thankYouTotalLabel.text = "You have tipped \(totalTipsString) so far! 🤩"
        thankYouTotalLabel.isHidden = totalTipsString.isEmpty
    }

    private func connectingToStoreFailed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {
                return
            }

            self.loadingLabel.text = "Could not connect to store."
            self.loadingIndicator.stopAnimating()
        }
    }

    private func purchaseActive(for view: UIView) {
        tipViewsStackView.arrangedSubviews.forEach {
            guard let tipView = $0 as? TipView else {
                return
            }

            tipView.setEnabled(false)
            tipView.setActive(tipView == view)
        }
    }

    private func purchaseStopped() {
        tipViewsStackView.arrangedSubviews.forEach {
            guard let tipView = $0 as? TipView else {
                return
            }

            tipView.setEnabled(true)
            tipView.setActive(false)
        }
    }

    private func purchaseCompleted(for product: SKProduct) {
        configureThankYouView(with: product)

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.storeView.alpha = 0
            }) { _ in
                UIView.animate(withDuration: 0.25) {
                    self.storeView.isHidden = true
                    self.thankYouView.isHidden = false
                }
            }
        }
    }

    private func updateTextColor(with color: UIColor) {
        [loadingLabel, topLabel, bottomLabel, totalTipsLabel, thankYouLabel, thankYouTotalLabel].forEach { $0?.textColor = color }
    }
}

extension TipJarViewController: TipViewDelegate {
    func tipView(_ view: UIView, didSelect product: SKProduct) {
        purchaseActive(for: view)

        storeManager.purchase(product) { [weak self] success in
            guard let self = self else {
                return
            }

            debugPrint("complete \(product.productIdentifier) with \(success)")

            self.purchaseStopped()
            if success {
                self.purchaseCompleted(for: product)
            }
        }
    }
}
