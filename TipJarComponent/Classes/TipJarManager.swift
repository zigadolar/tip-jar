//
//  TipJarManager.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import UIKit

public class TipJarManager: NSObject {

    private var window: TipJarWindow?

    public var hasReceivedTips: Bool {
        return !TipPersistenceManager.shared.tips.isEmpty
    }

    public func tipJarViewController(with model: TipJarViewController.Model) -> TipJarViewController? {
        let storyboard = UIStoryboard(name: "TipJar", bundle: Bundle.resourceBundle(for: self.classForCoder))
        guard let controller = storyboard.instantiateInitialViewController() as? TipJarViewController else {
            return nil
        }

        controller.configure(with: model)
        controller.delegate = self

        return controller
    }

    public func start(with model: TipJarViewController.Model) {
        showTipJarScreen(with: model)
    }

    // MARK: - Private

    private func showTipJarScreen(with model: TipJarViewController.Model) {
        let newWindow = TipJarWindow(frame: UIScreen.main.bounds)
        newWindow.windowLevel = .normal
        newWindow.rootViewController = BackgroundViewController()
        newWindow.makeKeyAndVisible()

        window = newWindow

        presentTipJarScreen(with: model)
    }

    private func presentTipJarScreen(with model: TipJarViewController.Model) {
        guard let controller = tipJarViewController(with: model) else {
            return
        }

        controller.standalone = true

        DispatchQueue.main.async {
            self.window?.rootViewController?.present(controller, animated: true)
        }
    }
}

extension TipJarManager: TipJarViewControllerDelegate {
    public func tipJarViewControllerWillDismiss(_ controller: UIViewController) {
        window?.dismissBackground(animated: true)
    }

    public func tipJarViewControllerDidDismiss(_ controller: UIViewController) {
        window?.isHidden = true
        window = nil
    }
}
