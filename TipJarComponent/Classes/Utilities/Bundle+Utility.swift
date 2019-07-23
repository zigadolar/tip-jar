//
//  Bundle+Utility.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

internal extension Bundle {
    static func resourceBundle(for type: AnyClass) -> Bundle? {
        let frameworkBundle = Bundle(for: type)
        let frameworkName = frameworkBundle.resourceURL?.deletingPathExtension().lastPathComponent
        if let pathToResourceBundle = frameworkBundle.path(forResource: frameworkName, ofType: "bundle") {
            if let bundle = Bundle(path: pathToResourceBundle) {
                return bundle
            }
        }
        return nil
    }
}
