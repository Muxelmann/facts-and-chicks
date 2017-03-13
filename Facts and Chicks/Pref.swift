//
//  PreferenceData.swift
//  Facts and Chicks - Menu
//
//  Created by Maximilian Zangs on 24.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Foundation


class Pref {
    
    fileprivate static let defaults = UserDefaults.standard
    fileprivate static let appID = "facts-and-chicks-app:"
    
    fileprivate static let hasStartedKey = appID + "app-started-once-before"
    static var hasStarted: Bool {
        get {
            return defaults.bool(forKey: hasStartedKey)
        }
    }
    
    fileprivate static let showPreferencesKey = appID + "show-preferences-upon-start"
    static var showPreferences: Bool {
        get {
            return defaults.bool(forKey: showPreferencesKey)
        }
        set {
            defaults.set(newValue, forKey: showPreferencesKey)
            appHasStarted()
        }
    }
    
    fileprivate static let saveDirectoryKey = appID + "save-directory-key"
    class var saveDirectory: URL {
        get {
            if let url = defaults.url(forKey: saveDirectoryKey) {
                return url
            } else {
                let array = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in:  FileManager.SearchPathDomainMask.userDomainMask)
                return array.first!
                //return NSURL(fileURLWithPath: "~/Downloads")
            }
        }
        set {
            defaults.set(newValue, forKey: saveDirectoryKey)
            appHasStarted()
        }
    }
    
    fileprivate static let lastWindowLocationKey = appID + "last-window-location-key"
    static var lastWindowLocation: NSRect? {
        get {
            if let data = defaults.object(forKey: lastWindowLocationKey) as? Data {
                if let value = NSKeyedUnarchiver.unarchiveObject(with: data) {
                    return (value as AnyObject).rectValue
                }
            }
            return nil
        }
        set {
            if let rect = newValue {
                let value = NSValue(rect: rect)
                let data = NSKeyedArchiver.archivedData(withRootObject: value)
                defaults.set(data, forKey: lastWindowLocationKey)
            }
            appHasStarted()
        }
    }
    
    fileprivate static let lastChickURLKey = appID + "last-chick-url"
    class var lastChickURL: URL? {
        get {
            return defaults.url(forKey: lastChickURLKey)
        }
        set {
            defaults.set(newValue, forKey: lastChickURLKey)
            appHasStarted()
        }
    }
    
    fileprivate static let fixDimensionKey = appID + "fix-dimension"
    static var fixDimension: Int {
        get {
            let width = defaults.bool(forKey: fixDimensionKey + "-width")
            let height = defaults.bool(forKey: fixDimensionKey + "-height")
            
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
            
            defaults.set(width, forKey: fixDimensionKey + "-width")
            defaults.set(height, forKey: fixDimensionKey + "-height")
        }
    }
    
    fileprivate static let fixSizeKey = appID + "fix-size"
    static var fixSize: CGSize {
        get {
            var width = 640
            if defaults.integer(forKey: fixSizeKey + "-width") != 0 {
                width = defaults.integer(forKey: fixSizeKey + "-width")
            }
            var height = 960
            if defaults.integer(forKey: fixSizeKey + "-height") != 0 {
                height = defaults.integer(forKey: fixSizeKey + "-height")
            }
        
            return CGSize(width: width, height: height)
        }
        set {
            defaults.set(Int(round(newValue.width)), forKey: fixSizeKey + "-width")
            defaults.set(Int(round(newValue.height)), forKey: fixSizeKey + "-height")
        }
    }
    
    fileprivate static let barButtonImageKey = appID + "bar-button-image"
    class var barButtonImage: String? {
        get {
            if let name = defaults.string(forKey: barButtonImageKey) {
                return name
            } else {
                return "starBarButtonImage"
            }
        }
        set {
            defaults.set(newValue, forKey: barButtonImageKey)
            appHasStarted()
        }
    }
    
    class func clearAllPresets() -> Bool {
        if let bundle = Bundle.main.bundleIdentifier {
            Pref.defaults.removePersistentDomain(forName: bundle)
            Pref.showPreferences = true
            return true
        } else {
            return false
        }
    }
    
    fileprivate class func appHasStarted() {
        defaults.set(true, forKey: hasStartedKey)
    }
    
}
