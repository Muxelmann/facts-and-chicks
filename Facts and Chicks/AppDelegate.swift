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
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var isStatusItemSetup = false
    
    let popover = NSPopover()
    
    var leftMouseEvent: EventMonitor?
    
    var window: NSWindow!
    
    var postCounter: NSMenuItem?
    var lastUpdate: NSMenuItem?
    
    // MARK: - AppDelegate
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.chickNotification(_:)), name: NSNotification.Name(rawValue: "chickNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.barChangedNotification(_:)), name: NSNotification.Name.NSWindowDidMove, object: nil)
        
        popover.animates = true
        popover.contentViewController = ChickViewController()
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.openPreferences(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Select Menu Chicks", action: nil, keyEquivalent: ""))
        menu.items.last?.submenu = getChickSelectMenu()
        menu.addItem(NSMenuItem(title: "Reset App", action: #selector(AppDelegate.resetApp(_:)), keyEquivalent: "R"))
        menu.addItem(NSMenuItem.separator())
        
        if let postCount = FactsAndChicks.postCount {
            menu.addItem(NSMenuItem(title: "Posts: \(postCount)", action: nil, keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "Posts: n/a", action: nil, keyEquivalent: ""))
        }
        postCounter = menu.items.last!
        
        if let updated = FactsAndChicks.lastPostDate {
            let formatter = DateFormatter()
            let dateFormat = DateFormatter.dateFormat(fromTemplate: "d MMM y", options: 0, locale: Locale.current)
            formatter.dateFormat = dateFormat
            menu.addItem(NSMenuItem(title: "Updated on " + formatter.string(from: updated as Date), action: nil, keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "Cannot connect", action: nil, keyEquivalent: ""))
        }
        lastUpdate = menu.items.last!
        
        menu.addItem(NSMenuItem.separator())
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
        
        leftMouseEvent = EventMonitor(mask: [NSEventMask.leftMouseDown, NSEventMask.rightMouseDown], handler: {[unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
            if self.window.isVisible {
                self.closePreferences(event)
            }
            })
        leftMouseEvent?.start()
        
        for aWindow in NSApplication.shared().windows {
            if aWindow.isKind(of: NSWindow.self) {
                window = aWindow
                if !Pref.showPreferences && Pref.hasStarted {
                    self.closePreferences(nil)
                }
            }
        }
        
        isStatusItemSetup = true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Functionality
    
    func resetApp(_ sender: AnyObject?) {
        if window.isVisible {
            closePreferences(sender)
        }
        
        if popover.isShown {
            closePopover(sender)
        }
        
        _ = Pref.clearAllPresets()
        if let button = statusItem.button {
            button.image = NSImage(named: Pref.barButtonImage!)
        }
    }
    
    func getChickSelectMenu() -> NSMenu {
        
        let imageSelectMenu = NSMenu()
        
        imageSelectMenu.addItem(NSMenuItem(title: "Just facts", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.items.last!.image = NSImage(named: "starBarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Facts for one", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.items.last!.image = NSImage(named: "chick1BarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Facts for two", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.items.last!.image = NSImage(named: "chick2BarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Nice facts", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.items.last!.image = NSImage(named: "chick4BarButtonImage")
        
        imageSelectMenu.addItem(NSMenuItem(title: "Even more facts", action: #selector(AppDelegate.changeMenuImage(_:)), keyEquivalent: ""))
        imageSelectMenu.items.last!.image = NSImage(named: "chick3BarButtonImage")
        
        //imageSelectMenu.addItem(NSMenuItem(title: "Clever facts", action: "changeMenuImage:", keyEquivalent: ""))
        //imageSelectMenu.itemArray.last!.image = NSImage(named: "chick5BarButtonImage")
        
        return imageSelectMenu
    }
    
    func changeMenuImage(_ sender: AnyObject) {
        if let button = statusItem.button {
            if let image = (sender as? NSMenuItem)?.image {
                button.image = image
                Pref.barButtonImage = image.name()
            }
        }
    }
    
    // MARK: - Chick model notification
    
    func chickNotification(_ notification: Notification) {
        if !isStatusItemSetup {
            return
        }
        
        if let postCount = FactsAndChicks.postCount {
            postCounter?.title = "Posts: \(postCount)"
        } else {
            postCounter?.title = "Posts: n/a"
        }
        
        if let updated = FactsAndChicks.lastPostDate {
            let formatter = DateFormatter()
            let dateFormat = DateFormatter.dateFormat(fromTemplate: "d MMM y", options: 0, locale: Locale.current)
            formatter.dateFormat = dateFormat
            lastUpdate?.title = "Updated on " + formatter.string(from: updated as Date)
        } else {
            lastUpdate?.title = "Cannot connect"
        }
    }
    
    func barChangedNotification(_ notification: Notification) {
        if let object = notification.object {
            if (object as AnyObject).description.contains("NSStatusBarWindow") && popover.isShown{
                closePopover(notification as AnyObject?)
            }
        }
    }
    
    // MARK: - Show and hide popover & window
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            leftMouseEvent?.start()
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        leftMouseEvent?.stop()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPreferences(_ sender: AnyObject?) {
        window.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
        window.becomeFirstResponder()
    }
    
    func closePreferences(_ sender: AnyObject?) {
        window.orderOut(sender)
        window.resignFirstResponder()
    }
    
    func openPreferences(_ sender: AnyObject?) {
        if window.isVisible {
            closePreferences(sender)
        } else {
            showPreferences(sender)
        }
        
    }
    
}

