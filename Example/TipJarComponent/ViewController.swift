//
//  ViewController.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import UIKit

import TipJarComponent

class ViewController: UIViewController {

    lazy var tipJarManager = TipJarManager()

    lazy var tipJarModel: TipJarViewController.Model = {
        let model = TipJarViewController.Model(products: ["small.tip.product.identifier": "🥑"],
                                               topText: "Top text.",
                                               bottomText: "Bottom text. ☺️")
        return model
    }()

    @IBAction func showStandaloneTipJar(_ sender: UIButton) {
        tipJarManager.start(with: tipJarModel)
    }

    @IBAction func showInlineTipJar(_ sender: UIButton) {
        guard let tipJarController = tipJarManager.tipJarViewController(with: tipJarModel) else {
            return
        }

        tipJarController.delegate = self
        tipJarController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissController))

        let navController = UINavigationController(rootViewController: tipJarController)

        present(navController, animated: true)
    }


    @objc func dismissController() {
        dismiss(animated: true)
    }
}

extension ViewController: TipJarViewControllerDelegate {
    func tipJarViewControllerWillDismiss(_ controller: UIViewController) {

    }

    func tipJarViewControllerDidDismiss(_ controller: UIViewController) {
        
    }
}

