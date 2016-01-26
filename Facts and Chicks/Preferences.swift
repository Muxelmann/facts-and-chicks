//
//  PreferencesViewController.swift
//  Facts and Chicks - Menu
//
//  Created by Maximilian Zangs on 24.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController, NSOpenSavePanelDelegate {

    @IBOutlet weak var background: BackgroundImageView!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var author: NSTextField!
    @IBOutlet weak var showPreferencesUponStart: NSButton!
    @IBOutlet weak var saveDirButton: NSButton!
    @IBOutlet weak var fixDimension: NSPopUpButton!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var height: NSTextField!
    
    var myWindow: NSWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("Clearing all Prefs: \(Pref.clearAllPresets())")
    }
    
    override func viewWillAppear() {
        version.stringValue = "1.0.0"
        author.stringValue = "Max Z."
        

        if let lastLocation = Pref.lastWindowLocation {
            myWindow.setFrame(lastLocation, display: true)
        }
        
        if Pref.hasStarted && !Pref.showPreferences {
            showPreferencesUponStart.state = 0
        } else {
            showPreferencesUponStart.state = 1
        }
        
        if let folder = Pref.saveDirectory.lastPathComponent {
            saveDirButton.title = "/" + folder
        } else {
            saveDirButton.title = "UNKNOWN"
        }
        
        let fixVal = Pref.fixDimension
        var savedItem: NSMenuItem? = nil
        for item in fixDimension.itemArray {
            switch (item.title, fixVal) {
            case ("none", 0): fallthrough
            case ("height", 1): fallthrough
            case ("width", 2):
                savedItem = item
            default: break
            }
        }
        fixDimension.selectItem(savedItem)
        
        let fixSize = Pref.fixSize
        width.stringValue = Int(fixSize.width).description
        height.stringValue = Int(fixSize.height).description
        
    }
    
    override func viewWillDisappear() {
        Pref.lastWindowLocation = myWindow.frame
    }
    
    @IBAction func fixSize(sender: NSPopUpButton) {
        if let item = sender.selectedItem {
            switch item.title {
            case "width":
                Pref.fixDimension = 2
            case "height":
                Pref.fixDimension = 1
            default:
                resetSizes()
                Pref.fixDimension = 0
            }
        } else {
            print("Fix neither height not width")
            Pref.fixDimension = 0
            
        }
    }
    
    @IBAction func changeSize(sender: NSSlider) {
        var savedSize = Pref.fixSize
        
        if sender.identifier == "heightSlider" {
            let heightVal = round(Float(sender.stringValue)!)
            savedSize.height = CGFloat(heightVal)
            height.stringValue = Int(heightVal).description
        } else if sender.identifier == "widthSlider" {
            let widthVal = round(Float(sender.stringValue)!)
            savedSize.width = CGFloat(widthVal)
            width.stringValue = Int(widthVal).description
        }
        
        Pref.fixSize = savedSize
    }
    
    func resetSizes() {
        width.stringValue = "640"
        height.stringValue = "960"
        Pref.fixSize = CGSize(width: 640, height: 960)
    }
    
    @IBAction func toggleShow(sender: NSButton) {
        Pref.showPreferences = (sender.state == 1)
    }
    
    @IBAction func saveDiretcory(sender: NSButton) {
        
        let openDlg = NSOpenPanel()
        openDlg.canChooseFiles = false
        openDlg.canCreateDirectories = true
        openDlg.canChooseDirectories = true
        openDlg.allowsMultipleSelection = false
        
        if openDlg.runModal() == NSModalResponseOK {
            if let directoryURL = openDlg.directoryURL {
            
                if let folder = directoryURL.lastPathComponent {
                    Pref.saveDirectory = directoryURL
                    saveDirButton.title = "/" + folder
                }
            }
        } else {
            print("aww...")
        }
    }
    
    func panelSelectionDidChange(sender: AnyObject?) {
        print(sender)
    }
}

class PreferencesWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.movableByWindowBackground = true
        
        if let preferences = self.contentViewController as? PreferencesViewController {
            preferences.myWindow = self.window
        }
    }
    
}


class BackgroundImageView: NSImageView {
    
    override var mouseDownCanMoveWindow: Bool {
        get {
            return true
        }
    }
    
}