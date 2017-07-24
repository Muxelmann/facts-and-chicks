//
//  ChicksInfo.swift
//  Facts and Chicks
//
//  Created by Maximilian Zangs on 25.01.16.
//  Copyright © 2016 Maximilian Zangs. All rights reserved.
//

import Cocoa

class FactsAndChicks {
    
    fileprivate static let apiKey = "YKKVEwP0oC4E0LYZcr4zk5fGlw8TdllGNHwUV528IeonfXirJN"
    
    fileprivate static func getJSONText(_ urlString: String) -> String {
        if let url = URL(string: urlString) {
            do {
                let text = try String(contentsOf: url, encoding: String.Encoding.utf8)
                isPageReachableBool = true
                return text
            } catch {
                print("NO CONNECTION: Could not load page")
            }
        }
        isPageReachableBool = false
        return ""
    }
    
    fileprivate static var isPageReachableBool = false {
        willSet {
            if mainInfo != nil {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "chickNotification"), object: nil)
            }
        }
    }
    static var isReachable: Bool {
        get { return isPageReachableBool }
    }
    
    fileprivate static func parseJSONString(_ text: String) -> [String:AnyObject]? {
        if text.isEmpty || !isReachable {
            return nil
        }
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                return json
            } catch let error as NSError {
                print("PARSING ERROR: Could not parse JSON text")
                print(error)
            }
        }
        return nil
    }
    
    fileprivate static func getData(_ urlString: String) -> [String:AnyObject]? {
        return parseJSONString(getJSONText(urlString + apiKey))
    }
    
    // MARK: - get main information only
    
    fileprivate static let mainInfoURL = "https://api.tumblr.com/v2/blog/factsandchicks.com/info?api_key="
    fileprivate static var mainInfo: [String:AnyObject]?
    
    static var postCount: Int? {
        get {
            if mainInfo == nil {
                mainInfo = getData(mainInfoURL)
            }
            
            
            if let posts = ((mainInfo?["response"] as! [String: AnyObject]?)?["blog"] as! [String: AnyObject]?)?["posts"] as? Int {
                return posts
            }
            return nil
        }
    }
    
    static var lastPostDate: Date? {
        get {
            if mainInfo == nil {
                mainInfo = getData(mainInfoURL)
                print(mainInfo!)
            }
            
            if let updated = ((mainInfo?["response"] as! [String: AnyObject]?)?["blog"] as! [String: AnyObject]?)?["updated"] as? Int {
                return Date(timeIntervalSince1970: Double(updated))
            }
            return nil
        }
    }
    
    // MARK: - load single post information
    
    fileprivate let postInfoURL = "https://api.tumblr.com/v2/blog/factsandchicks.com/posts?limit=1&offset=<POST_ID>&api_key="
    fileprivate var postInfo: [String:AnyObject]?
    fileprivate var postSummary: (URL?, String?, URL?) = (nil, nil, nil)
    
    fileprivate func loadPost(_ id: Int) {
        var postID = id
        if FactsAndChicks.postCount != nil && id >= FactsAndChicks.postCount! || id < 0 {
            postID = 0
        }
        postInfo = FactsAndChicks.getData(postInfoURL.replacingOccurrences(of: "<POST_ID>", with: "\(postID)"))
        
        var url: URL?
        var fact: String?
        var source: URL?
        
        if let info = postInfo {
        
            if let photoURL = (((((info["response"] as! [String: AnyObject]?)?["posts"] as! [AnyObject])[0] as! NSDictionary).value(forKey: "photos") as! [NSDictionary])[0].value(forKey: "original_size") as! NSDictionary).value(forKey: "url") as? String {
                url = URL(string: photoURL)
            }
            
            if let stuff = (((info["response"] as! [String: AnyObject]?)?["posts"] as! [AnyObject]?)?.first as! [String: AnyObject]?)?["caption"] as? String {
                if !stuff.isEmpty {
                    
                    let factIndexStart = stuff.range(of: "<p>")?.upperBound
                    let factIndexEnd = stuff.range(of: "</p>")?.lowerBound
                    
                    if factIndexStart != nil && factIndexEnd != nil {
                        fact = stuff.substring(with: factIndexStart!..<factIndexEnd!)
                        //fact = stuff.substringWithRange(Range<String.Index>(start: factIndexStart!, end: factIndexEnd!))
                    }
                    
                    let sourceIndexStart = stuff.range(of: "<a href=\"")?.upperBound
                    let sourceIndexEnd = stuff.range(of: "\" target=\"_blank\">")?.lowerBound
                    
                    if sourceIndexStart != nil && sourceIndexEnd != nil {
                        source = URL(string: stuff.substring(with: sourceIndexStart!..<sourceIndexEnd!))
                        //source = NSURL(string: stuff.substringWithRange(Range<String.Index>(start: sourceIndexStart!, end: sourceIndexEnd!)))
                    }
                    
                }
            }
        }
        
        postSummary = (url, fact, source)
    }
    
    fileprivate func loadRandomPost() {
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
                if let image = NSImage(contentsOf: url) {
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
    
    var source: URL? {
        return postSummary.2
    }
    
}
