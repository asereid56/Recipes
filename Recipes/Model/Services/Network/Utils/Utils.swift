//
//  Utils.swift
//  Recipes
//
//  Created by Aser Eid on 13/08/2024.
//

import UIKit
import Reachability

func isInternetAvailable() -> Bool {
    let reachability = try! Reachability()
    switch reachability.connection {
    case .wifi, .cellular:
        return true
    case .unavailable:
        return false
    }
}

func checkInternetAndShowToast(vc: UIViewController) -> Bool{
    if isInternetAvailable() {
        return true
    } else {
        showAlert(message: "No internet connection", vc: vc)
        return false
    }
}

func showAlert(message: String, vc: UIViewController) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}
