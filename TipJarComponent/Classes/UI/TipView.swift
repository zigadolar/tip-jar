//
//  TipView.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import UIKit
import StoreKit

protocol TipViewDelegate: AnyObject {
    func tipView(_ view: UIView, didSelect product: SKProduct)
}

class TipView: UIView {

    weak var delegate: TipViewDelegate?

    @IBOutlet private var containerView: UIView!

    @IBOutlet private var emojiLabel: UILabel!
    @IBOutlet private(set) var descriptionLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private var product: SKProduct?

    init()
    {
        super.init(frame: CGRect.zero)
        
        loadFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
    }

    func configure(with product: SKProduct, emoji: String? = nil) {
        self.product = product

        setupView(with: product, emoji: emoji)
    }

    func setEnabled(_ enabled: Bool) {
        purchaseButton.isEnabled = enabled
    }

    func setActive(_ active: Bool) {
        purchaseButton.titleLabel?.alpha = active ? 0 : 1
        active ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func purchaseButtonTapped(_ sender: UIButton) {
        guard let product = product else {
            return
        }

        delegate?.tipView(self, didSelect: product)
    }

    // MARK: - Private

    private func setupView(with product: SKProduct, emoji: String?) {
        descriptionLabel.text = product.localizedTitle
        emojiLabel.text = emoji

        let formatter: NumberFormatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        purchaseButton.setTitle(formatter.string(from: product.price), for: .normal)
    }
}
