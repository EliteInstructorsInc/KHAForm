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
        
        // Remove checkmark from old selected cell
        let oldSelectedCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0))
        oldSelectedCell?.accessoryType = .None
        
        // Add checkmark to new selected cell
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        selectedIndex = indexPath.row
        delegate?.selectionFormDidChangeSelectedIndex(self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}