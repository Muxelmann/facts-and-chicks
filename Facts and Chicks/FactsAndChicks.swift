//
//  ChicksInfo.swift
//  Facts and Chicks
//
//  Created by Maximilian Zangs on 25.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Cocoa

class FactsAndChicks {
    private static let apiKey = "YKKVEwP0oC4E0LYZcr4zk5fGlw8TdllGNHwUV528IeonfXirJN"
    
    private static func getJSONText(urlString: String) -> String {
        if let url = NSURL(string: urlString) {
            do {
                let text = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                isPageReachableBool = true
                return text
            } catch {
                print("NO CONNECTION: Could not load page")
            }
        }
        isPageReachableBool = false
        return ""
    }
    
    private static var isPageReachableBool = false {
        willSet {
            if mainInfo != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("chickNotification", object: nil)
            }
        }
    }
    static var isReachable: Bool {
        get { return isPageReachableBool }
    }
    
    private static func parseJSONString(text: String) -> [String:AnyObject]? {
        if text.isEmpty || !isReachable {
            return nil
        }
        
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                return json
            } catch let error as NSError {
                print("PARSING ERROR: Could not parse JSON text")
                print(error)
            }
        }
        return nil
    }
    
    private static func getData(urlString: String) -> [String:AnyObject]? {
        return parseJSONString(getJSONText(urlString + apiKey))
    }
    
    // MARK: - get main information only
    
    private static let mainInfoURL = "https://api.tumblr.com/v2/blog/factsandchicks.com/info?api_key="
    private static var mainInfo: [String:AnyObject]?
    
    static var postCount: Int? {
        get {
            if mainInfo == nil {
                mainInfo = getData(mainInfoURL)
            }
            
            if let info = mainInfo {
                if let response = info["response"] {
                    if let blog = response["blog"] {
                        if let posts = blog?["posts"] as? Int {
                            return posts
                        }
                    }
                }
            }
            return nil
        }
    }
    
    static var lastPostDate: NSDate? {
        get {
            if mainInfo == nil {
                mainInfo = getData(mainInfoURL)
                print(mainInfo)
            }
            
            if let info = mainInfo {
                if let response = info["response"] {
                    if let blog = response["blog"] {
                        if let updated = blog?["updated"] as? Int {
                            return NSDate(timeIntervalSince1970: Double(updated))
                        }
                    }
                }
            }
            return nil
        }
    }
    
    // MARK: - load single post information
    
    private let postInfoURL = "https://api.tumblr.com/v2/blog/factsandchicks.com/posts?limit=1&offset=<POST_ID>&api_key="
    private var postInfo: [String:AnyObject]?
    private var postSummary: (NSURL?, String?, NSURL?) = (nil, nil, nil)
    
    private func loadPost(id: Int) {
        var postID = id
        if id >= FactsAndChicks.postCount || id < 0 {
            postID = 0
        }
        postInfo = FactsAndChicks.getData(postInfoURL.stringByReplacingOccurrencesOfString("<POST_ID>", withString: "\(postID)"))
        
        var url: NSURL?
        var fact: String?
        var source: NSURL?
        
        if let info = postInfo {
            if let photoURL = info["response"]!["posts"]!!.firstObject!!["photos"]!!.firstObject!!["original_size"]!!["url"]! as? String {
                url = NSURL(string: photoURL)
            }
            
            if let stuff = info["response"]!["posts"]!!.firstObject!!["caption"]! as? String {
                if !stuff.isEmpty {
                    
                    let factIndexStart = stuff.rangeOfString("<p>")?.endIndex
                    let factIndexEnd = stuff.rangeOfString("</p>")?.startIndex
                    
                    if factIndexStart != nil && factIndexEnd != nil {
                        fact = stuff.substringWithRange(Range<String.Index>(start: factIndexStart!, end: factIndexEnd!))
                    }
                    
                    let sourceIndexStart = stuff.rangeOfString("<a href=\"")?.endIndex
                    let soruceIndexEnd = stuff.rangeOfString("\" target=\"_blank\">")?.startIndex
                    
                    if sourceIndexStart != nil && soruceIndexEnd != nil {
                        source = NSURL(string: stuff.substringWithRange(Range<String.Index>(start: sourceIndexStart!, end: soruceIndexEnd!)))
                    }
                    
                }
            }
        }
        
        postSummary = (url, fact, source)
    }
    
    private func loadRandomPost() {
        let postID = Int(arc4random()) % (FactsAndChicks.postCount ?? 1)
        loadPost(postID)
    }
    
    var newImage: NSImage? {
        loadRandomPost()
        return image
    }
    
    var image: NSImage {
        get {
            if let url = postSummary.0 {
                if let image = NSImage(contentsOfURL: url) {
                    return image
                }
            }
            return NSImage(named: "noConnection")!
        }
    }
    
    var imageName: String {
        get {
            return postSummary.0?.lastPathComponent ?? ""
        }
    }
    
    var fact: String? {
        return postSummary.1
    }
    
    var source: NSURL? {
        return postSummary.2
    }
    
}