//
//  SideMenuWebViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/30/20.
//

import UIKit
import WebKit
import Lottie

class SideMenuWebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    private var animationView: AnimationView?
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
       
        animationView = .init(name: "loading")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.75
        view.addSubview(animationView!)
        animationView!.play()
       // let url = URL(string: "https://tonnelier.tech")!

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let url = defaults.string(forKey: "url")
        print ("FUCK MY LIFE")
        webView.load(URLRequest(url:  URL(string: url ?? "https://vidushimeel.github.io/tonnelier/index.html")!))

        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        animationView?.isHidden = true

   }
}
