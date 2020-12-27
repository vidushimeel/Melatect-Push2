//
//  MenuViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/30/20.
//

import UIKit
import StoreKit

class SideMenuViewController: UIViewController, UITableViewDataSource, loadWebView {
    let defaults = UserDefaults.standard

    func loadWebView(titleLabel: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuWebViewController") as UIViewController
        
        if titleLabel == "Help Center"{
            //need to record video
            defaults.set("https://tnlrtechnologies.com/openSourceInfo.html", forKey: "url")
        }
        else if titleLabel == "Feedback"{
            //redirects to app store 
            var components = URLComponents(url: URL(string: "https://apps.apple.com/us/app/melatect/id1544199337")!, resolvingAgainstBaseURL: false)
            components?.queryItems = [
              URLQueryItem(name: "action", value: "write-review")
            ]
            guard let writeReviewURL = components?.url else {
              return
            }
            UIApplication.shared.open(writeReviewURL)
        }
        else if titleLabel == "Coming Soon"{
            defaults.set("https://tnlrtechnologies.com/ComingSoon.html", forKey: "url")
        }
        else if titleLabel == "FAQ"{
            defaults.set("https://vidushimeel.github.io/tonnelier/openSourceInfo.html", forKey: "url")
        }
        else if titleLabel == "Legal"{
            defaults.set("https://tnlrtechnologies.com/legal.html", forKey: "url")
        }
        else {
            //contact us
            defaults.set("https://www.linkedin.com/company/tonnelier-tech/", forKey: "url")
        }
        self.present(vc, animated: true, completion: nil)
    }
    
 
    @IBOutlet weak var sideMenuTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SideMenuTableViewCell", bundle: nil)
        self.sideMenuTableView.register(nib, forCellReuseIdentifier: "SideMenuTableViewCell")
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.sideMenuTableView.backgroundColor = UIColor.clear
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath) as! SideMenuTableViewCell
        cell.delegate = self
        if indexPath.row == 0{
            cell.cellTitleLabel.text = "Help Center"
        }
        else if indexPath.row == 1{
            cell.cellTitleLabel.text = "Feedback"
        }
        else if indexPath.row == 2{
            cell.cellTitleLabel.text = "Coming Soon"
        }
        else if indexPath.row == 3{
            cell.cellTitleLabel.text = "FAQ"
        }
        else if indexPath.row == 4{
            cell.cellTitleLabel.text = "Legal"
        }
        else {
            cell.cellTitleLabel.text = "Contact us"
        }
        
        return cell
    }
}
