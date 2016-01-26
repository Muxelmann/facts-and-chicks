//
//  ChickViewController.swift
//  Facts and Chicks - Menu
//
//  Created by Maximilian Zangs on 23.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Cocoa


class ChickViewController: NSViewController, NSUserNotificationCenterDelegate {

    let facts = FactsAndChicks()
    
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var refreshButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var refreshButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var downloadButton: NSButton!
    
    var chickPic: NSImage? {
        didSet {
            if let pic = chickPic {
                
                // let scale = CGFloat(arc4random() % 100) / CGFloat(100)
                let aspect = pic.size.width / pic.size.height
                let fixSize = Pref.fixSize
                
                var width: CGFloat
                var height: CGFloat
                switch Pref.fixDimension {
                case 1:
                    // print("fix width \(fixSize)")
                    width = fixSize.height * aspect
                    height = fixSize.height
                case 2:
                    // print("fix height \(fixSize)")
                    width = fixSize.width
                    height = fixSize.width / aspect
                default:
                    // print("Fix none \(fixSize)")
                    width = pic.size.width
                    height = pic.size.height
                }
                
                var maxHeight: CGFloat
                var maxWidth: CGFloat
                maxHeight = NSScreen.mainScreen()!.visibleFrame.height - CGFloat(50)
                maxWidth = NSScreen.mainScreen()!.visibleFrame.width - CGFloat(50)
                
                if height > maxHeight {
                    height = maxHeight
                    width = maxHeight * aspect
                }
                
                if width > maxWidth {
                    height = maxWidth / aspect
                    width = maxWidth
                }
                
                refreshButtonHeight.animator().constant = height
                refreshButtonWidth.animator().constant = width
                
                refreshButton.image = pic
                loadingIndicator.hidden = true
                loadingIndicator.stopAnimation(nil)
                refreshButton.enabled = true
                downloadButton.enabled = true
            }
        }
    }
    
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    private let miniSize = 200.0
    
    override func viewWillAppear() {
        view.wantsLayer = true
        refreshButtonHeight.constant = CGFloat(miniSize)
        refreshButtonWidth.constant = CGFloat(miniSize)
        loadNewImage()
    }
    
    override func viewDidDisappear() {
        refreshButtonHeight.constant = CGFloat(miniSize)
        refreshButtonWidth.constant = CGFloat(miniSize)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        // center.removeAllDeliveredNotifications()
        center.deliveredNotifications
        for (i, deliveredNotification) in center.deliveredNotifications.enumerate() {
            if i > 0 {
                center.removeDeliveredNotification(deliveredNotification)
            }
        }
        
        return true
    }
    
    @IBAction func refresh(sender: AnyObject) {
        loadNewImage()
    }
    
    @IBAction func downloadImage(sender: AnyObject) {
        
        if let path = Pref.saveDirectory.path {
            // print(path)
            
            // if let image = chickPic {
            //     image.savePNG(path + "/chick.png")
            // }
            
            if !facts.imageName.isEmpty {
                facts.image.savePNG(path + "/" + facts.imageName)
            }
            
        }
        downloadButton.enabled = false
    }
    
    @IBAction func showSource(sender: AnyObject) {
        if let url = facts.source {
            NSWorkspace.sharedWorkspace().openURL(url)
        } else {
            let notification = NSUserNotification()
            notification.title = "Source issue"
            notification.subtitle = "Facts and Chicks"
            notification.informativeText = "This chick does not come with a source"
            notification.soundName = nil
            
        
            NSSound(named: "uh-oh")?.play()
        
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        }
    }
    
    private func loadNewImage() {
        
        refreshButton.image = nil
        
        loadingIndicator.startAnimation(nil)
        loadingIndicator.hidden = false
        
        refreshButton.enabled = false
        downloadButton.enabled = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let newChickPic = self.facts.newImage
            dispatch_async(dispatch_get_main_queue(), {
                self.chickPic = newChickPic
            })
        })
    }
}

extension NSImage {
    var imagePNGRepresentation: NSData {
        return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSPNGFileType, properties: [:])!
    }
    func savePNG(path:String) -> Bool {
        return imagePNGRepresentation.writeToFile(path, atomically: true)
    }
}