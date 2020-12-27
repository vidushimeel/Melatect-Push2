//
//  TakeOrChoosePhotoOfMoleViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/21/20.
//

import UIKit
import CoreML
import Vision
import RealmSwift

class DisplayDiagnosisViewController: UIViewController {
    /* used for draggable page
     https://fluffy.es/facebook-draggable-bottom-card-modal-1/
     */
    
    enum CardViewState {
        case expanded
        case normal
    }
    //CARD ANIMATION VARIABLES
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var handleView: UIView!
    
    var cardViewState : CardViewState = .normal
    var cardPanStartingTopConstraint: CGFloat = 0
    var cardPanStartingTopConstant : CGFloat = 30.0
    var backingImage: UIImage?
    
    
    //VARIABLES
    @IBOutlet weak var moleImageView: UIImageView!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var diagnosisSubLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    
    var pictureOfMole: UIImage?
    var passedInMole = MoleEntry()
    
    var xcood = Double()
    var ycood = Double()
    let realm = try! Realm()
    
    var LoadExistingDiagnosis = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadCardAnimationMethods()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LoadExistingDiagnosis == false{
            saveButton.layer.cornerRadius = 10
            guard let model = try? VNCoreMLModel(for: moleScanDetectorModel1_copy().model) else {
                fatalError("Loading CoreML Model Failed.")
            }
            let request = VNCoreMLRequest(model: model) { (request, error) in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Model failed to process image.")
                }
                if let firstResult = results.first {
                    self.diagnosisLabel.text = firstResult.identifier.capitalized
                }
            }
            let handler = VNImageRequestHandler(ciImage: CIImage(image: self.moleImageView.image!)!)
            do {
                try handler.perform([request])
            }
            catch {
                print(error)
            }
            xButton.isHidden = true
        }
        else {
            self.moleImageView.image = UIImage(data: (passedInMole.imageOfMole!) as Data)
            self.diagnosisLabel.text = passedInMole.diagnosis
            saveButton.isHidden = true
        }
        
        if diagnosisLabel.text == "Malignant" || diagnosisLabel.text == "The mole present may be malignant"{
            cardView.backgroundColor = #colorLiteral(red: 1, green: 0.8461767401, blue: 0.849131756, alpha: 1)
            diagnosisLabel.textColor = #colorLiteral(red: 0.9983811975, green: 0.3601943254, blue: 0.2774392366, alpha: 1)
            diagnosisLabel.textColor = #colorLiteral(red: 1, green: 0.5621168613, blue: 0.5568934083, alpha: 1)

            diagnosisLabel.text = "The mole present may be malignant"
            diagnosisSubLabel.text = "We reccomend contacting your health care provider immediately or getting in touch with a specialist using the MyDoctors page tab. If you believe there has been a mistake, please contact our team."
        }
        else {
            cardView.backgroundColor = #colorLiteral(red: 0.9121155143, green: 0.9780873656, blue: 0.8993980289, alpha: 1)
            diagnosisLabel.textColor  = #colorLiteral(red: 0.2605797648, green: 0.5291824341, blue: 0.3093243837, alpha: 1)
            diagnosisLabel.text = "The mole present may be benign"
            diagnosisSubLabel.textColor = #colorLiteral(red: 0.3665700024, green: 0.7417052292, blue: 0.4350099593, alpha: 1)
            diagnosisSubLabel.text = "We recommend you contact a dermatologist for an evaluation if concerns about your mole persist. If you believe there has been a mistake, please contact our team."

        }
        showCard()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        do {
            try self.realm.write{
                let newEntry = MoleEntry()
                newEntry.positionOnBodyXCoordinate = xcood
                newEntry.positionOnBodyYCoordinate = ycood
                newEntry.diagnosis = diagnosisLabel.text!
                let data = NSData(data: moleImageView.image!.pngData()!)
                newEntry.imageOfMole = data
                realm.add(newEntry)
            }
        }
        catch{
            print (error)
        }
        hideCardAndGoBack()
    }
    
    @IBAction func xButtonPressed(_ sender: UIButton) {
        hideCardAndGoBack()
    }
    
    
    
    
    
    
    //MARK: - Card Animation Titles
    
    func viewDidLoadCardAnimationMethods(){
        backingImageView.image = backingImage
        moleImageView.image = pictureOfMole
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
           let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        dimmerView.alpha = 0.0
        
        
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
        
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        
        self.view.addGestureRecognizer(viewPan)
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 3.0
    }
    
    
    
    private func showCard(atState: CardViewState = .normal) {
        self.view.layoutIfNeeded()
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
           let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            
            if atState == .expanded {
                cardViewTopConstraint.constant = 30.0
            } else {
                cardViewTopConstraint.constant = (safeAreaHeight + bottomPadding) / 2.0
            }
            
            cardPanStartingTopConstraint = cardViewTopConstraint.constant
        }
        let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.layoutIfNeeded()
        })
        showCard.addAnimations {
            self.dimmerView.alpha = 0.7
        }
        showCard.startAnimation()
    }
    
    
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideCardAndGoBack()
    }
    private func hideCardAndGoBack() {
        self.view.layoutIfNeeded()
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
           let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        let hideCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.layoutIfNeeded()
        })
        hideCard.addAnimations {
            self.dimmerView.alpha = 0.0
        }
        hideCard.addCompletion({ position in
            if position == .end {
                if(self.presentingViewController != nil) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        })
        hideCard.startAnimation()
    }
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
        let velocity = panRecognizer.velocity(in: self.view)
        let translation = panRecognizer.translation(in: self.view)
        
        switch panRecognizer.state {
        case .began:
            cardPanStartingTopConstant = cardViewTopConstraint.constant
            
        case .changed:
            if self.cardPanStartingTopConstraint + translation.y > 30.0 {
                self.cardViewTopConstraint.constant = self.cardPanStartingTopConstant + translation.y
            }
            dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.cardViewTopConstraint.constant)
            
        case .ended:
            if velocity.y > 1500.0 {
                hideCardAndGoBack()
                return
            }
            
            if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
               let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                
                if self.cardViewTopConstraint.constant < (safeAreaHeight + bottomPadding) * 0.25 {
                    showCard(atState: .expanded)
                } else if self.cardViewTopConstraint.constant < (safeAreaHeight) - 70 {
                    showCard(atState: .normal)
                } else {
                    hideCardAndGoBack()
                }
            }
        default:
            break
        }
    }
    
    
    private func dimAlphaWithCardTopConstraint(value: CGFloat) -> CGFloat {
        let fullDimAlpha : CGFloat = 0.7
        guard let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
              let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {
            return fullDimAlpha
        }
        let fullDimPosition = (safeAreaHeight + bottomPadding) / 2.0
        let noDimPosition = safeAreaHeight + bottomPadding
        if value < fullDimPosition {
            return fullDimAlpha
        }
        if value > noDimPosition {
            return 0.0
        }
        return fullDimAlpha * 1 - ((value - fullDimPosition) / fullDimPosition)
    }
}
