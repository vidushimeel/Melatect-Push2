//
//  PreviewToSignUpViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/3/20.
//

import UIKit
import Lottie

class PreviewToSignUpViewController: UIViewController {


    @IBOutlet weak var animationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.loopMode = .loop
        animationView.play()
        

    }
  

}
