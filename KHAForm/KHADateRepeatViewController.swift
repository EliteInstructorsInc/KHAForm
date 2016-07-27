//
//  KHADateRepeatViewController.swift
//  Pods
//
//  Created by Jonathan Lu on 7/27/16.
//
//

import Foundation

public class KHADateRepeatViewController: KHASelectionFormViewController {
    
    public var selectedIndices : [Int] = []
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Remove checkmark from old selected cell
        let oldSelectedCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0))
        oldSelectedCell?.accessoryType = .None
        
        // Add checkmark to new selected cell
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        selectedIndex = indexPath.row
                
        delegate?.dateRepeatDidChangeSelectedIndex(self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}