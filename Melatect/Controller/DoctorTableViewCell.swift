//
//  DoctorTableViewCell.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/5/20.
//

import UIKit
import RealmSwift

protocol GrowingCellProtocol: class {
    func updateHeightOfRow(_ cell: DoctorTableViewCell, _ textView: UITextView)
}

protocol PhoneNumberDelegate: class {
    func phoneButtonTapped(cell: DoctorTableViewCell)
}


protocol EmailDelegate: class {
    func emailButtonTapped(cell: DoctorTableViewCell)
}


class DoctorTableViewCell: UITableViewCell{
    weak var cellDelegate: GrowingCellProtocol?
    weak var phoneDelegate: PhoneNumberDelegate?
    weak var emailDelegate: EmailDelegate?
    
    @IBOutlet weak var doctorTableViewCellView: UIView!
    @IBOutlet weak var doctorTypeTextView: UITextView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var phoneNumberTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doctorTableViewCellView.layer.cornerRadius = 15
        
        doctorTypeTextView.layer.cornerRadius = 9
        nameTextView.layer.cornerRadius = 9
        emailTextView.layer.cornerRadius = 9
        phoneNumberTextView.layer.cornerRadius = 9
        
        doctorTypeTextView.tintColor = #colorLiteral(red: 0.6116471291, green: 0.6115076542, blue: 0.6280091405, alpha: 1)
        nameTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        emailTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        phoneNumberTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        
        doctorTypeTextView.spellCheckingType = UITextSpellCheckingType.no
        nameTextView.spellCheckingType = UITextSpellCheckingType.no
        emailTextView.spellCheckingType = UITextSpellCheckingType.no
        phoneNumberTextView.spellCheckingType = UITextSpellCheckingType.no

        doctorTypeTextView.delegate = self
        nameTextView.delegate = self
        emailTextView.delegate = self
        phoneNumberTextView.delegate = self
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        self.phoneDelegate?.phoneButtonTapped(cell: self)
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
       self.emailDelegate?.emailButtonTapped(cell: self)
    }
}


extension DoctorTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let deletate = cellDelegate {
            deletate.updateHeightOfRow(self, textView)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
