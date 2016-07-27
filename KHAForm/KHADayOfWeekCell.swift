//
//  KHADayOfWeekCell.swift
//  Pods
//
//  Created by Jonathan Lu on 7/27/16.
//
//

import Foundation
import UIKit

class KHADayOfWeekCell: KHAFormCell {
    
    class var cellID: String {
        return "KHADayOfWeekCell"
    }
    
    private let kFontSize: CGFloat = 15
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        
        button.setTitle("NEED 5 BUTTONS", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(kFontSize)
        button.titleLabel?.textAlignment = .Center
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        
        contentView.addConstraints([
            NSLayoutConstraint(
                item: button,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: contentView,
                attribute: .Left,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: contentView,
                attribute: .Right,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: 44)]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}