//
//  KHADateRepeatCell.swift
//  Pods
//
//  Created by Jonathan Lu on 7/27/16.
//
//

import Foundation
import UIKit

class KHADateRepeatCell: KHAFormCell {
    
    class var cellID: String {
        return "KHADateRepeatCell"
    }
    
    override var selectionFormViewController: KHASelectionFormViewController {
        willSet {
            detailTextLabel?.text = newValue.selections[newValue.selectedIndex]
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = "Repeat"
        detailTextLabel?.text = "None"
        accessoryType = .DisclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}