//
//  KhaMultipleSelectionViewController.swift
//  Elite Instructor
//
//  Created by Jonathan Lu on 7/25/16.
//  Copyright © 2016 Eric Heitmuller. All rights reserved.
//

import Foundation

public class KHAMultipleSelectionFormViewController: KHASelectionFormViewController {
    
    public var selectedIndices : [Int] = []
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if(cell?.accessoryType.rawValue == 0) {
            cell?.accessoryType = .Checkmark
            selectedIndices.append(indexPath.row)
        } else if(cell?.accessoryType == .Checkmark) {
            cell?.accessoryType = .None
            selectedIndices = selectedIndices.filter({ $0 != indexPath.row })
        }

        delegate?.multipleSelectionFormDidChangeSelectedIndex(self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}