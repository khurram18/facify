//
//  InfoViewController.swift
//  Facify
//
//  Created by Khurram on 28/03/2018.
//  Copyright © 2018 Khurram. All rights reserved.
//
import WebKit
import UIKit

class InfoViewController: UIViewController {

@objc func onDoneTap() {
    presentingViewController?.dismiss(animated: true, completion: nil)
}
override func viewDidLoad() {
    super.viewDidLoad()
    guard let url = Bundle.main.url(forResource: "acknowledgements", withExtension: "html") else {
        return
    }
    configureToolbar()
    appDescriptionLabel.text = appDescription
    webView.load(URLRequest(url: url))
}
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}
private func configureToolbar() {
    let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(onDoneTap))
    let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    let label = UILabel()
    label.text = "Acknowledgements"
    label.textAlignment = .center
    label.textColor = .black
    let titleItem = UIBarButtonItem(customView: label)
    let secondSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    toolbar.items = [doneItem, spacer, titleItem, secondSpacer]
}
private var appDescription: String {
    guard let infoDictionary = Bundle.main.infoDictionary else {
        return ""
    }
    guard let name = infoDictionary["CFBundleName"] as? String else {
        return ""
    }
    guard let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String else {
        return name
    }
    guard let minorVersion = infoDictionary["CFBundleVersion"] as? String else {
        return "\(name), Version \(majorVersion)"
    }
    return "\(name), Version \(majorVersion) (\(minorVersion))"
}
@IBOutlet weak var appDescriptionLabel: UILabel!
@IBOutlet weak var toolbar: UIToolbar!
@IBOutlet weak var webView: WKWebView!
}
