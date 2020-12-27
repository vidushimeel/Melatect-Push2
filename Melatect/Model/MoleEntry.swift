//
//  MoleEntry.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/23/20.
//
import Foundation
import RealmSwift

class MoleEntry: Object{

    @objc dynamic var positionOnBodyXCoordinate: Double = 0.0
    @objc dynamic var positionOnBodyYCoordinate: Double  = 0.0
    @objc dynamic var diagnosis: String = ""
    @objc dynamic var imageOfMole: NSData?
}
