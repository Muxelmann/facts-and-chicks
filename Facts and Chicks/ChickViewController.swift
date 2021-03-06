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
    @IBOutlet weak var sourceButton: NSButton!
    
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
                maxHeight = NSScreen.main()!.visibleFrame.height - CGFloat(50)
                maxWidth = NSScreen.main()!.visibleFrame.width - CGFloat(50)
                
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
                loadingIndicator.isHidden = true
                loadingIndicator.stopAnimation(nil)
                refreshButton.isEnabled = true
                downloadButton.isEnabled = true
            }
        }
    }
    
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSUserNotificationCenter.default.delegate = self
    }
    
    fileprivate let miniSize = 200.0
    
    override func viewWillAppear() {
        // view.wantsLayer = true
        refreshButtonHeight.constant = CGFloat(miniSize)
        refreshButtonWidth.constant = CGFloat(miniSize)
        loadNewImage()
    }
    
    override func viewDidDisappear() {
        refreshButtonHeight.constant = CGFloat(miniSize)
        refreshButtonWidth.constant = CGFloat(miniSize)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // center.removeAllDeliveredNotifications()
        _ = center.deliveredNotifications
        for (i, deliveredNotification) in center.deliveredNotifications.enumerated() {
            if i > 0 {
                center.removeDeliveredNotification(deliveredNotification)
            }
        }
        
        return true
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        loadNewImage()
    }
    
    @IBAction func downloadImage(_ sender: AnyObject) {
        
        let path = Pref.saveDirectory.path
        // print(path)
        
        // if let image = chickPic {
        //     image.savePNG(path + "/chick.png")
        // }
        
        if !facts.imageName.isEmpty {
            _ = facts.image.savePNG(path + "/" + facts.imageName)
        }
        
        downloadButton.isEnabled = false
    }
    
    @IBAction func showSource(_ sender: AnyObject) {
        if let url = facts.source {
            NSWorkspace.shared().open(url as URL)
        } else {
            let notification = NSUserNotification()
            notification.title = "Source issue"
            notification.subtitle = "Facts and Chicks"
            notification.informativeText = "This chick does not come with a source"
            notification.soundName = nil
            
        
            NSSound(named: "uh-oh")?.play()
        
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    fileprivate func loadNewImage() {
        
        refreshButton.image = nil
        
        loadingIndicator.startAnimation(nil)
        loadingIndicator.isHidden = false
        
        refreshButton.isEnabled = false
        downloadButton.isEnabled = false
        
        DispatchQueue.global().async(execute: {
            let newChickPic = self.facts.newImage
            DispatchQueue.main.async(execute: {
                self.chickPic = newChickPic
            })
        })
    }
}

extension NSImage {
    var imagePNGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    func savePNG(_ path:String) -> Bool {
        return ((try? imagePNGRepresentation.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil)
    }
}
