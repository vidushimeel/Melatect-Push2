//
//  UIView+Snapshot.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/22/20.
//

import Foundation
import UIKit

extension UIView  {
    // render the view within the view's bounds, then capture it as image
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image(actions: { rendererContext in
        layer.render(in: rendererContext.cgContext)
    })
  }
}
