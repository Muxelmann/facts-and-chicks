//
//  AppDelegate.swift
//  Facts and Chicks - Menu
//
//  Created by Maximilian Zangs on 23.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var isStatusItemSetup = false
    
    let popover = NSPopover()
    
    var leftMouseEvent: EventMonitor?
    
    var window: NSWindow!
    
    var postCounter: NSMenuItem?
    var lastUpdate: NSMenuItem?
    
    // MARK: - AppDelegate
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.chickNotification(_:)), name: "chickNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.barChangedNotification(_:)), name: NSWindowDidMoveNotification, object: nil)
        
        popover.animates = true
        popover.contentViewController = ChickViewController()
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.openPreferences(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Select Menu Chicks", action: nil, keyEquivalent: ""))
        menu.itemArray.last?.submenu = getChickSelectMenu()
        menu.addItem(NSMenuItem(title: "Reset App", action: #selector(AppDelegate.resetApp(_:)), keyEquivalent: "R"))
        menu.addItem(NSMenuItem.separatorItem())
        
        if let postCount = FactsAndChicks.postCount {
            menu.addItem(NSMenuItem(title: "Posts: \(postCount)", action: nil, keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "Posts: n/a", action: nil, keyEquivalent: ""))
        }
        postCounter = menu.itemArray.last!
        
        if let updated = FactsAndChicks.lastPostDate {
            let formatter = NSDateFormatter()
            let dateFormat = NSDateFormatter.dateFormatFromTemplate("d MMM y", options: 0, locale: NSLocale.currentLocale())
            formatter.dateFormat = dateFormat
            menu.addItem(NSMenuItem(title: "Updated on " + formatter.stringFromDate(updated), action: nil, keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "Cannot connect", action: nil, keyEquivalent: ""))
        }
        lastUpdate = menu.itemArray.last!
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit Facts and Chicks", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.image = NSImage(named: Pref.barButtonImage!)
            
            let leftGesture = NSClickGestureRecognizer()
            leftGesture.buttonMask = 0x1
            leftGesture.target = self
            leftGesture.action = #selector(AppDelegate.togglePopover(_:))
            button.addGestureRecognizer(leftGesture)
        }
        
        leftMouseEvent = EventMonitor(mask: [NSEventMask.LeftMouseDownMask, NSEventMask.RightMouseDownMask], handler: {[unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
            if self.window.visible {
                self.closePreferences(event)
            }
            })
        leftMouseEvent?.start()
        
        for aWindow in NSApplication.sharedApplication().windows {
            if aWindow.isKindOfClass(NSWindow) {
                window = aWindow
                if !Pref.showPreferences && Pref.hasStarted {
                    self.closePreferences(nil)
                }
            }
        }
        
        isStatusItemSetup = true
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Functionality
    
    func resetApp(sender: AnyObject?) {
        if window.visible {
            closePreferences(sender)
        }
        
        if popover.shown {
            closePopover(sender)
        }
        
        Pref.clearAllPresets()
        if let button = statusItem.button {
            button.image = NSImage(named: Pref.barButtonImage!)
        }
    }
    
    func getChickSelectMenu() -> NSMenu {
        
        let imageSelectMenu = NSMenu()
        
        imageSelectMenu.addItem(NSMenuItem(title: "Just facts", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.itemArray.last!.image = NSImage(named: "starBarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Facts for one", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.itemArray.last!.image = NSImage(named: "chick1BarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Facts for two", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.itemArray.last!.image = NSImage(named: "chick2BarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Nice facts", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.itemArray.last!.image = NSImage(named: "chick4BarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Even more facts", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.itemArray.last!.image = NSImage(named: "chick3BarButtonImage")
        
        //imageSelectMenu.addItem(NSMenuItem(title: "Clever facts", action: "changeMenuImage:", keyEquivalent: ""))
        //imageSelectMenu.itemArray.last!.image = NSImage(named: "chick5BarButtonImage")
        
        return imageSelectMenu
    }
    
    func changeMenuImage(sender: AnyObject) {
        if let button = statusItem.button {
            if let image = (sender as? NSMenuItem)?.image {
                button.image = image
                Pref.barButtonImage = image.name()
            }
        }
    }
    
    // MARK: - Chick model notification
    
    func chickNotification(notification: NSNotification) {
        if !isStatusItemSetup {
            return
        }
        
        if let postCount = FactsAndChicks.postCount {
            postCounter?.title = "Posts: \(postCount)"
        } else {
            postCounter?.title = "Posts: n/a"
        }
        
        if let updated = FactsAndChicks.lastPostDate {
            let formatter = NSDateFormatter()
            let dateFormat = NSDateFormatter.dateFormatFromTemplate("d MMM y", options: 0, locale: NSLocale.currentLocale())
            formatter.dateFormat = dateFormat
            lastUpdate?.title = "Updated on " + formatter.stringFromDate(updated)
        } else {
            lastUpdate?.title = "Cannot connect"
        }
    }
    
    func barChangedNotification(notification: NSNotification) {
        if let object = notification.object {
            if object.description.containsString("NSStatusBarWindow") && popover.shown{
                closePopover(notification)
            }
        }
    }
    
    // MARK: - Show and hide popover & window
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
            leftMouseEvent?.start()
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        leftMouseEvent?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPreferences(sender: AnyObject?) {
        window.makeKeyAndOrderFront(sender)
        NSApp.activateIgnoringOtherApps(true)
        window.becomeFirstResponder()
    }
    
    func closePreferences(sender: AnyObject?) {
        window.orderOut(sender)
        window.resignFirstResponder()
    }
    
    func openPreferences(sender: AnyObject?) {
        if window.visible {
            closePreferences(sender)
        } else {
            showPreferences(sender)
        }
        
    }
    
}

