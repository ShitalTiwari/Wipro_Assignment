//
//  CommonMethods.swift
//  iOS_Wipro
//
//  Created by SierraVista Technologies Pvt Ltd on 09/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//  This class manages all common method needed in application

import UIKit

class CommonMethods: NSObject {

    //This method calculates height for given text based on width and font provoded
    static func getCellHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        var height = 60.0 as CGFloat
        
        //Creating dummy label to get height for label
        let sampleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        sampleLabel.numberOfLines = 0
        sampleLabel.lineBreakMode = .byWordWrapping
        sampleLabel.font = UIFont.systemFont(ofSize: 17.0)
        sampleLabel.text = text
        sampleLabel.sizeToFit()
        
        if sampleLabel.bounds.height > height {
            height = sampleLabel.bounds.height
        }
        
        return height
    }
    
}
