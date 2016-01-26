//
//  PreferenceData.swift
//  Facts and Chicks - Menu
//
//  Created by Maximilian Zangs on 24.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Foundation


class Pref {
    
    private static let defaults = NSUserDefaults.standardUserDefaults()
    private static let appID = "facts-and-chicks-app:"
    
    private static let hasStartedKey = appID + "app-started-once-before"
    static var hasStarted: Bool {
        get {
            return defaults.boolForKey(hasStartedKey)
        }
    }
    
    private static let showPreferencesKey = appID + "show-preferences-upon-start"
    static var showPreferences: Bool {
        get {
            return defaults.boolForKey(showPreferencesKey)
        }
        set {
            defaults.setBool(newValue, forKey: showPreferencesKey)
            appHasStarted()
        }
    }
    
    private static let saveDirectoryKey = appID + "save-directory-key"
    class var saveDirectory: NSURL {
        get {
            if let url = defaults.URLForKey(saveDirectoryKey) {
                return url
            } else {
                let array = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:  NSSearchPathDomainMask.UserDomainMask)
                return array.first!
                //return NSURL(fileURLWithPath: "~/Downloads")
            }
        }
        set {
            defaults.setURL(newValue, forKey: saveDirectoryKey)
            appHasStarted()
        }
    }
    
    private static let lastWindowLocationKey = appID + "last-window-location-key"
    static var lastWindowLocation: NSRect? {
        get {
            if let data = defaults.objectForKey(lastWindowLocationKey) as? NSData {
                if let value = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
                    return value.rectValue
                }
            }
            return nil
        }
        set {
            if let rect = newValue {
                let value = NSValue(rect: rect)
                let data = NSKeyedArchiver.archivedDataWithRootObject(value)
                defaults.setObject(data, forKey: lastWindowLocationKey)
            }
            appHasStarted()
        }
    }
    
    private static let lastChickURLKey = appID + "last-chick-url"
    class var lastChickURL: NSURL? {
        get {
            return defaults.URLForKey(lastChickURLKey)
        }
        set {
            defaults.setURL(newValue, forKey: lastChickURLKey)
            appHasStarted()
        }
    }
    
    private static let fixDimensionKey = appID + "fix-dimension"
    static var fixDimension: Int {
        get {
            let width = defaults.boolForKey(fixDimensionKey + "-width")
            let height = defaults.boolForKey(fixDimensionKey + "-height")
            
            switch (width, height) {
            case (false, false): return 0
            case (false, true): return 1
            case (true, false): return 2
            case (true, true): return 0
            }
        }
        set {
            var height: Bool!
            var width: Bool!
            
            switch newValue {
            case 1:
                width = false
                height = true
            case 2:
                width = true
                height = false
            default:
                width = false
                height = false
            }
            
            defaults.setBool(width, forKey: fixDimensionKey + "-width")
            defaults.setBool(height, forKey: fixDimensionKey + "-height")
        }
    }
    
    private static let fixSizeKey = appID + "fix-size"
    static var fixSize: CGSize {
        get {
            var width = 640
            if defaults.integerForKey(fixSizeKey + "-width") != 0 {
                width = defaults.integerForKey(fixSizeKey + "-width")
            }
            var height = 960
            if defaults.integerForKey(fixSizeKey + "-height") != 0 {
                height = defaults.integerForKey(fixSizeKey + "-height")
            }
        
            return CGSize(width: width, height: height)
        }
        set {
            defaults.setInteger(Int(round(newValue.width)), forKey: fixSizeKey + "-width")
            defaults.setInteger(Int(round(newValue.height)), forKey: fixSizeKey + "-height")
        }
    }
    
    private static let barButtonImageKey = appID + "bar-button-image"
    class var barButtonImage: String? {
        get {
            if let name = defaults.stringForKey(barButtonImageKey) {
                return name
            } else {
                return "starBarButtonImage"
            }
        }
        set {
            defaults.setObject(newValue, forKey: barButtonImageKey)
            appHasStarted()
        }
    }
    
    class func clearAllPresets() -> Bool {
        if let bundle = NSBundle.mainBundle().bundleIdentifier {
            Pref.defaults.removePersistentDomainForName(bundle)
            Pref.showPreferences = true
            return true
        } else {
            return false
        }
    }
    
    private class func appHasStarted() {
        defaults.setBool(true, forKey: hasStartedKey)
    }
    
}