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
@IBOutlet weak var webView: WKWebView!
@IBAction func onDoneTap(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
}
override func viewDidLoad() {
    super.viewDidLoad()
    guard let url = Bundle.main.url(forResource: "acknowledgements", withExtension: "html") else {
        return
    }
    webView.load(URLRequest(url: url))
}
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}
}
