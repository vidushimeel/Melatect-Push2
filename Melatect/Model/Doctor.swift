//
//  Doctor.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/14/20.
//

import Foundation
import RealmSwift

class Doctor: Object {

    @objc dynamic var doctorType: String = ""
    @objc dynamic var name: String  = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var email: String = ""

}

