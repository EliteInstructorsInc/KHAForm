//
//  KHAFormController.swift
//  KHAForm
//
//  Created by Kohei Hayakawa on 2/20/15.
//  Copyright (c) 2015 Kohei Hayakawa. All rights reserved.
//

import UIKit

public protocol KHAFormViewDataSource {
     func formCellsInForm(form: KHAFormViewController) -> [[KHAFormCell]]
}

public
class KHAFormViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, KHAFormViewDataSource, KHASelectionFormViewDelegate {
    
    private var cells = [[KHAFormCell]]()
    private var datePickerIndexPath: NSIndexPath?
    private var customInlineCellIndexPath: NSIndexPath?
    
    private var repeatCellIndexPath: NSIndexPath?
    private var dayOfWeekCellIndexPath: NSIndexPath?
    
    private var lastIndexPath: NSIndexPath? // For selection form cell
    
    // Form is always grouped tableview
    convenience public init() {
        self.init(style: .Grouped)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // init form structure
        reloadForm()
    }
    
    public func reloadForm() {
        cells = formCellsInForm(self)
        tableView.reloadData()
    }
    
    /*! Determine form structure by using two-dimensional array.
        First index determines section and second index determines row.
        This method must be overridden in subclass.
    */
    public func formCellsInForm(form: KHAFormViewController) -> [[KHAFormCell]] {
        return  cells
    }

    public func formCellForIndexPath(indexPath: NSIndexPath) -> KHAFormCell {
        var before = false
        if hasInlineDatePicker() {
            before = (datePickerIndexPath?.row < indexPath.row) && (datePickerIndexPath?.section == indexPath.section)
        }
        else if hasInlineCustomCell() {
            before = (customInlineCellIndexPath?.row < indexPath.row && customInlineCellIndexPath?.section == indexPath.section)
        }
        
        let row = (before ? indexPath.row - 1 : indexPath.row)

        var cell = dequeueReusableFormCellWithType(.DatePicker)
        if hasCustomCellAtIndexPath(indexPath) {
            cell = cells[indexPath.section][row-1]
            if let inlineCell = cell.customInlineCell where customInlineCellIndexPath == indexPath {
                cell = inlineCell
            }
        }
        else if (!hasPickerAtIndexPath(indexPath) || !hasCustomCellAtIndexPath(indexPath)) && indexPath != datePickerIndexPath {
            cell = cells[indexPath.section][row]
        }
        return cell
    }
    
    public func dequeueReusableFormCellWithType(type: KHAFormCellType) -> KHAFormCell {
        // Register the picker cell if form has a date cell and still not registered
        if type == .Date && tableView.dequeueReusableCellWithIdentifier(type.cellID()) == nil {
            tableView.registerClass(KHADatePickerFormCell.self, forCellReuseIdentifier: KHADatePickerFormCell.cellID)
        }
        // Register initialized cell if form doesn't have that cell
        if let cell = tableView.dequeueReusableCellWithIdentifier(type.cellID()) as? KHAFormCell {
            return cell
        } else {
            tableView.registerClass(type.cellClass(), forCellReuseIdentifier: type.cellID())
            return tableView.dequeueReusableCellWithIdentifier(type.cellID()) as! KHAFormCell
        }
    }

    // MARK: - UITableViewDataSource
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = formCellForIndexPath(indexPath)
        return cell.bounds.height
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cells.count
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePickerAtSection(section) || hasCustomInlineCellAtSection(section) {
            // we have a date picker, so allow for it in the number of rows in this section
            return cells[section].count + 1
        }
        return cells[section].count;
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = formCellForIndexPath(indexPath)
        
        if cell is KHATextFieldFormCell {
            cell.textField.delegate = self
        } else if cell is KHATextViewFormCell {
            cell.textView.delegate = self
        } else if cell is KHADatePickerFormCell {
            let dateCell = formCellForIndexPath(NSIndexPath(forRow: indexPath.row-1, inSection: indexPath.section))
            cell.datePicker.datePickerMode = dateCell.datePickerMode
            cell.datePicker.minuteInterval = dateCell.datePicker.minuteInterval
            cell.datePicker.addTarget(self, action: Selector("didDatePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! KHAFormCell

        if cell is KHADateFormCell {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else if cell is KHASelectionFormCell {
            lastIndexPath = indexPath
            let selectionFormViewController = cell.selectionFormViewController
            selectionFormViewController.delegate = self
            navigationController?.pushViewController(selectionFormViewController, animated: true)
        }
        else if cell.customInlineCell != nil {
            displayCustomInlineCellForRowAtIndexPath(indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        view.endEditing(true)
    }
    
    
    // MARK: - DatePicker
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
    */
    public func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            if let associatedDatePickerCell = tableView.cellForRowAtIndexPath(indexPath) {
                let cell = cells[indexPath.section][indexPath.row - 1] as! KHADateFormCell
                (associatedDatePickerCell as! KHADatePickerFormCell).datePicker.setDate(cell.date, animated: false)
            }
        }
    }
    
    private func hasInlineDatePickerAtSection(section: Int) -> Bool {
        if hasInlineDatePicker() {
            return datePickerIndexPath?.section == section
        }
        return false
    }
    
    private func hasCustomInlineCellAtSection(section: Int)-> Bool {
        if hasInlineCustomCell() {
            return customInlineCellIndexPath?.section == section
        }
        return false
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
        @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
    */
    private func hasPickerAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker() && (datePickerIndexPath?.row == indexPath.row) && (datePickerIndexPath?.section == indexPath.section)
    }
    
    private func hasCustomCellAtIndexPath(indexPath: NSIndexPath)->Bool {
        return hasInlineCustomCell() && (customInlineCellIndexPath?.row == indexPath.row) && (customInlineCellIndexPath?.section == indexPath.section)
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
    */
    private func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    private func hasInlineCustomCell()->Bool {
        return customInlineCellIndexPath != nil
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
        @param indexPath The indexPath to reveal the UIDatePicker.
    */
    private func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
        @param indexPath The indexPath to reveal the UIDatePicker.
    */
    private func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = (datePickerIndexPath?.row < indexPath.row) && (datePickerIndexPath?.section == indexPath.section)
        }
        
        let sameCellClicked = ((datePickerIndexPath?.row == indexPath.row + 1) && (datePickerIndexPath?.section == indexPath.section))
        
        // remove any date picker cell if it exists
        if hasInlineDatePicker() {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: datePickerIndexPath!.row, inSection: datePickerIndexPath!.section)], withRowAnimation: .Fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: indexPath.section)
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    private func displayCustomInlineCellForRowAtIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        var before = false
        if hasInlineCustomCell() {
            before = (customInlineCellIndexPath?.row < indexPath.row && customInlineCellIndexPath?.section == indexPath.section)
        }
        
        let sameCellClicked = ((customInlineCellIndexPath?.row == indexPath.row + 1 ) && customInlineCellIndexPath?.section == indexPath.section)
        
        // remove any other custom cell if it exists
        if let indexPath = customInlineCellIndexPath where hasInlineCustomCell() {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            customInlineCellIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old custom cell and display the new one
            let rowToReveal = before ? indexPath.row-1 : indexPath.row
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: indexPath.section)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPathToReveal.row+1, inSection: indexPathToReveal.section)], withRowAnimation: .Fade)
            customInlineCellIndexPath = NSIndexPath(forRow: indexPathToReveal.row+1, inSection: indexPathToReveal.section)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        tableView.endUpdates()
    }
    
    private func removeAnyDatePickerCell() {
        if hasInlineDatePicker() {
            tableView.beginUpdates()
            
            let indexPath = NSIndexPath(forRow: datePickerIndexPath!.row, inSection: datePickerIndexPath!.section)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            datePickerIndexPath = nil
            
            // always deselect the row containing the start or end date
            tableView.deselectRowAtIndexPath(indexPath, animated:true)
            
            tableView.endUpdates()
            
            // inform our date picker of the current date to match the current cell
            updateDatePicker()
        }
    }
    
    /*! User chose to change the date by changing the values inside the UIDatePicker.
        @param sender The sender for this action: UIDatePicker.
    */
    func didDatePickerValueChanged(sender: UIDatePicker) {
        
        var targetedCellIndexPath: NSIndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            targetedCellIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: datePickerIndexPath!.section)
        } else {
            // external date picker: update the current "selected" cell's date
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                targetedCellIndexPath = selectedIndexPath
            }
        }
        
        // update the cell's date string
        if let selectedIndexPath = targetedCellIndexPath {
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as! KHADateFormCell
            let targetedDatePicker = sender
            cell.date = targetedDatePicker.date
        }
    }
    
    
    // MARK: - Delegate
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        removeAnyDatePickerCell()
    }

    public func textViewDidBeginEditing(textView: UITextView) {
        removeAnyDatePickerCell()
    }
    
    func selectionFormDidChangeSelectedIndex(selectionForm: KHASelectionFormViewController) {
        let cell = tableView.cellForRowAtIndexPath(lastIndexPath!) as! KHASelectionFormCell
        cell.detailTextLabel?.text = selectionForm.selections[selectionForm.selectedIndex]
    }
    
    func multipleSelectionFormDidChangeSelectedIndex(selectionForm: KHAMultipleSelectionFormViewController) {
        let cell = tableView.cellForRowAtIndexPath(lastIndexPath!) as! KHASelectionFormCell
        
        if(selectionForm.selectedIndices.count == 0) {
            cell.detailTextLabel?.text = "None"
            return
        }
        
        if(selectionForm.selectedIndices.count == 1) {
            cell.detailTextLabel?.text = selectionForm.selections[selectionForm.selectedIndices[0]]
            return
        }
        
        cell.detailTextLabel?.text = String(selectionForm.selectedIndices.count) + "day(s)"
    }
    
    func dateRepeatDidChangeSelectedIndex(selectionForm: KHADateRepeatViewController) {
        let cell = tableView.cellForRowAtIndexPath(lastIndexPath!) as! KHASelectionFormCell
        cell.detailTextLabel?.text = selectionForm.selections[selectionForm.selectedIndex]
        
        if(selectionForm.selectedIndex == 0 && customInlineCellIndexPath != nil) {
            displayCustomInlineCellForRowAtIndexPath(lastIndexPath!)
        }
        
        //Selected index is not none
        if(selectionForm.selectedIndex > 0 && customInlineCellIndexPath == nil) {
            displayCustomInlineCellForRowAtIndexPath(lastIndexPath!)
        }
    }
}
