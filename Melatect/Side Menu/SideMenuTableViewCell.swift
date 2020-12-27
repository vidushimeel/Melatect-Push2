//
//  SideMenuTableViewCell.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/30/20.
//

import UIKit
protocol loadWebView: class{
    func loadWebView(titleLabel: String)
}

class SideMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitleLabel: UILabel!
    weak var delegate: loadWebView?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        delegate?.loadWebView(titleLabel: cellTitleLabel.text ?? "bro idk")
        print (delegate!)
       // let buttonPosition:CGPoint = cellTitleLabel.convert(CGPoint.zero, to:delegate.sideMenuTableView)
        print ("hihihi")
    }
    
}
