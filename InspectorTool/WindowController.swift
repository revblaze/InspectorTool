//
//  WindowController.swift
//  InspectorTool
//
//  Created by Justin Bush on 2018-08-03.
//  Copyright © 2018 Justin Bush. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        window!.delegate = self
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.windowController = self
        
    }

}
