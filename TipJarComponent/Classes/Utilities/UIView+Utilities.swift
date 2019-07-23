//
//  UIView.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import UIKit

extension UIView {
    func loadFromNib() {
        let nibName = String(describing: type(of: self))

        guard
            let bundle = Bundle.resourceBundle(for: type(of: self)),
            let views = bundle.loadNibNamed(nibName, owner: self, options: nil),
            let firstView = views.first as? UIView
            else { return }

        firstView.translatesAutoresizingMaskIntoConstraints = true
        firstView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        firstView.frame = bounds

        addSubview(firstView)
        backgroundColor = .clear
    }

    func roundCorners(_ radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }

    func dropShadow(offset: CGSize = CGSize(width: 1, height: 1),
                    color: UIColor = .black,
                    radius: CGFloat = 1,
                    opacity: Float = 0.25) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }

    func addBorder(width: CGFloat = 1, color: UIColor = .white) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
