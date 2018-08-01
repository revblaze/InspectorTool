//
//  ViewController.swift
//  InspectorTool
//
//  Created by Justin Bush on 2018-08-01.
//  Copyright © 2018 Justin Bush. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var infoTextView: NSTextView!
    @IBOutlet weak var saveInfoButton: NSButton!
    @IBOutlet weak var moveUpButton: NSButton!
    
    // MARK: - Properties
    
    var filesList: [URL] = []
    var showInvisibles = false
    
    var selectedFolder: URL? {
        didSet {
            if let selectedFolder = selectedFolder {
                filesList = contentsOf(folder: selectedFolder)
                selectedItem = nil
                self.tableView.reloadData()
                self.tableView.scrollRowToVisible(0)
                moveUpButton.isEnabled = true
                view.window?.title = selectedFolder.path
            } else {
                moveUpButton.isEnabled = false
                view.window?.title = "FileSpy"
            }
        }
    }
    
    var selectedItem: URL? {
        didSet {
            infoTextView.string = ""
            saveInfoButton.isEnabled = false
            
            guard let selectedUrl = selectedItem else {
                return
            }
            
            let infoString = infoAbout(url: selectedUrl)
            if !infoString.isEmpty {
                let formattedText = formatInfoText(infoString)
                infoTextView.textStorage?.setAttributedString(formattedText)
                saveInfoButton.isEnabled = true
            }
        }
    }
    
    // MARK: - View Lifecycle & error dialog utility
    /*
    override func viewDidLoad() {
        self.tableView.backgroundColor = NSColor.clear
        self.tableView.enclosingScrollView?.drawsBackground = false
        
    }
    
    func setTransparent() {
        let CustomView = MenuRowView()
        return CustomView
    }
 */
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        restoreCurrentSelections()
    }
    
    override func viewWillDisappear() {
        saveCurrentSelections()
        
        super.viewWillDisappear()
    }
    
    func showErrorDialogIn(window: NSWindow, title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
}

// MARK: - Getting file or folder information

extension ViewController {
    
    func contentsOf(folder: URL) -> [URL] {
        return []
    }
    
    func infoAbout(url: URL) -> String {
        return "No information available for \(url.path)"
    }
    
    func formatInfoText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 24
        paragraphStyle?.alignment = .left
        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 240) ]
        
        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14),
            NSAttributedStringKey.paragraphStyle: NSParagraphStyle.default
        ]
        
        let formattedText = NSAttributedString(string: text, attributes: textAttributes)
        return formattedText
    }
    
    
}

// MARK: - Actions

extension ViewController {
    
    @IBAction func selectFolderClicked(_ sender: Any) {
    }
    
    @IBAction func toggleShowInvisibles(_ sender: NSButton) {
    }
    
    @IBAction func tableViewDoubleClicked(_ sender: Any) {
    }
    
    @IBAction func moveUpClicked(_ sender: Any) {
    }
    
    @IBAction func moveDownClicked(_ sender: Any) {
    }
    
    @IBAction func saveInfoClicked(_ sender: Any) {
    }
    
}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filesList.count
    }
    
}

// MARK: - NSTableViewDelegate

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor
        tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 {
            selectedItem = nil
            return
        }
        
        selectedItem = filesList[tableView.selectedRow]
    }
    
}

// MARK: - Save & Restore previous selection

extension ViewController {
    
    func saveCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else { return }
        
        let parentForStorage = selectedFolder?.path ?? ""
        let fileForStorage = selectedItem?.path ?? ""
        let completeData = "\(parentForStorage)\n\(fileForStorage)\n"
        
        try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
    }
    
    func restoreCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else { return }
        
        do {
            let storedData = try String(contentsOf: dataFileUrl)
            let storedDataComponents = storedData.components(separatedBy: .newlines)
            if storedDataComponents.count >= 2 {
                if !storedDataComponents[0].isEmpty {
                    selectedFolder = URL(fileURLWithPath: storedDataComponents[0])
                    if !storedDataComponents[1].isEmpty {
                        selectedItem = URL(fileURLWithPath: storedDataComponents[1])
                        selectUrlInTable(selectedItem)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func selectUrlInTable(_ url: URL?) {
        guard let url = url else {
            tableView.deselectAll(nil)
            return
        }
        
        if let rowNumber = filesList.index(of: url) {
            let indexSet = IndexSet(integer: rowNumber)
            DispatchQueue.main.async {
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
        }
    }
    
    private func urlForDataStorage() -> URL? {
        return nil
    }
    
}

