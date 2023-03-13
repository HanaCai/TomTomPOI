//
//  Utility.swift
//  TestApp
//
//  Created by Hana Cai on 12/29/2022.
//

import Foundation
import UIKit

func metersFromMiles(_ miles: Double)-> Double{
    /// 1 mile is 1609.344 meters
    /// source: http://www.google.com/search?q=1+mile+in+meters
    /// for the region, miles radius should be multiplied by 2
    return 1609.344 * miles
}

func spanDegreeFromMiles(_ miles: Double)-> Double{
    /// 1 degree is approx 69 miles at the equator, thus span_degree with miles would be ( Miles / 69.0 )
    return miles/69.0
}



extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}


extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 90)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
