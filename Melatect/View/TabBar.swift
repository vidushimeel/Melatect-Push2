//
//  TabBar.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/10/20.
//

import UIKit

class TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
        self.selectedIndex = 1

    }
    
}
