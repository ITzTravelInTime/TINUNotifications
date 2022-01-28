/*
 TINUNotifications: A library to send notifications and alerts more easily within a macOS app.
 Copyright (C) 2021-2022 Pietro Caruso

 This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

import Foundation

#if os(macOS)
import AppKit
//import TINURecovery

///Class that is used to create and send notifications
open class Notification: Message{
    
    private init(id: String, message: String, description: String, imageData: Data?, scheduledTime: Date?, actionButtonTitle: String?, closeButtonTitle: String?, allowsSpam: Bool, usesRandomizedID: Bool?, actions: [Action]?, displayActionSelector: Bool?, replyPlaceholder: String?, userTag: [String: String]?) {
        self.id = id
        self.message = message
        self.description = description
        self.imageData = imageData
        self.scheduledTime = scheduledTime
        self.actionButtonTitle = actionButtonTitle
        self.closeButtonTitle = closeButtonTitle
        self.allowsSpam = allowsSpam
        self.usesRandomizedID = usesRandomizedID
        self.actions = actions
        self.displayActionSelector = displayActionSelector
        self.replyPlaceholder = replyPlaceholder
        self.userTag = userTag
    }
    
    public init(id: String, message: String, description: String, icon: Image? = nil, scheduledTime: Date? = nil, actionButtonTitle: String? = nil, closeButtonTitle: String? = nil, allowsSpam: Bool = false, usesRandomizedID: Bool? = nil, actions: [Action]? = nil, displayActionSelector: Bool? = nil, replyPlaceholder: String? = nil, userTag: [String: String]? = nil) {
        self.id = id
        self.message = message
        self.description = description
        self.icon = icon
        self.scheduledTime = scheduledTime
        self.actionButtonTitle = actionButtonTitle
        self.closeButtonTitle = closeButtonTitle
        self.allowsSpam = allowsSpam
        self.usesRandomizedID = usesRandomizedID
        self.actions = actions
        self.displayActionSelector = displayActionSelector
        self.replyPlaceholder = replyPlaceholder
        self.userTag = userTag
    }
    
    ///Creates a copy of this notification as a new instance
    public func copy() -> Self {
        return Notification(id: self.id, message: self.message, description: self.description, imageData: self.imageData, scheduledTime: self.scheduledTime, actionButtonTitle: self.actionButtonTitle, closeButtonTitle: self.closeButtonTitle, allowsSpam: self.allowsSpam, usesRandomizedID: self.usesRandomizedID, actions: self.actions, displayActionSelector: self.displayActionSelector, replyPlaceholder: self.replyPlaceholder, userTag: self.userTag) as! Self
    }
    
    public static func == (l: Notification, r: Notification) -> Bool {
        var res = l.message == r.message
        res = res && l.id == r.id
        res = res && l.description == r.description
        res = res && l.imageData == r.imageData
        res = res && l.scheduledTime == r.scheduledTime
        res = res && l.allowsSpam == r.allowsSpam
        res = res && l.closeButtonTitle == r.closeButtonTitle
        res = res && l.actionButtonTitle == r.actionButtonTitle
        res = res && l.actions == r.actions
        res = res && l.displayActionSelector == r.displayActionSelector
        res = res && l.replyPlaceholder == r.replyPlaceholder
        res = res && l.usesRandomizedID == r.usesRandomizedID
        
        return res
    }
    
    ///Used to make notifications app-specific/program-specific
    private static let idPrefix: String = (Bundle.main.bundleIdentifier ?? "TINUNotifications") + "."
    ///Counts the number of notifications to make the id unique for each one if needed
    private static var counter: UInt64 = 0
    ///Record of notifications ids and send times to have them delivered for not too much
    private static var prevIDs: [String: (Date, String)] = [:]
    ///Timer that undends notifications after 2 minutes
    private static var timer: Timer!
    
    ///The type used to store notification actions, consisting of action ID and disaply name
    public struct Action: Codable, Equatable{
        let id: String
        let displayName: String
    }
    
    ///The id of this notification
    public var id: String
    ///The title of the notification
    public var message: String
    ///The text debscribing the notification
    public var description: String
    
    ///Value used to store in memory the notification's image
    private var imageData: Data? = nil
    
    ///Value used to schedule the notification in a specific point in time
    public var scheduledTime: Date? = nil
    
    ///Value that specifies if the notification should have an action button and what it's title should be.
    public var actionButtonTitle: String? = nil
    
    ///Value that specifies if the notification should have a custom title and what that should be.
    public var closeButtonTitle: String? = nil
    
    ///Value used to determinate if this notification can be spammed or not
    public var allowsSpam: Bool = false
    
    ///The actions are used for additional notifications actions
    ///
    ///Will work only in OS X Yosemite 10.10 and later
    public var actions: [Action]? = nil
    
    ///Sets if the shown notification should display a selector to chose an action
    ///
    ///     The nil case is considered the same as false.
    ///
    ///     Warning: Makes use of private OS API, might not be safe turning this on for production apps.
    public var displayActionSelector: Bool? = nil
    
    ///Sets if the notification should have a reply button and what the reply text field placeholder text shuold be.
    ///
    ///     NOTE: An empty placeholder text will just display the Reply button.
    public var replyPlaceholder: String? = nil
    
    ///Array used to store custom information to pass to the notification hanlder
    public var userTag: [String: String]? = nil
    
    ///This specifies that the notification that is being created should have a randomized suffix added to it's id
    public var usesRandomizedID: Bool? = nil
    
    ///The icon used for the notification
    public var icon: Image?{
        get{
            guard let dat = imageData else { return nil }
            return Image(data: dat)
        }
        set{
            imageData = newValue?.tiffRepresentation
        }
    }
    
    ///Creates an `NSUserNotification` from the current instance
    public func create() -> NSUserNotification{
        let notification = NSUserNotification()
        
        if !Notification.prevIDs.keys.contains(id){
            notification.identifier = Notification.idPrefix + id + ((usesRandomizedID ?? false) ? "\(arc4random())" : "") + (allowsSpam ? String(Notification.counter) : "")
            
            Notification.prevIDs[id] = (Date(), notification.identifier!)
            
            Notification.counter += 1
            
            if Notification.timer == nil{
                Notification.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Notification.timer(_:)), userInfo: nil, repeats: true)
            }
        }else{
            notification.identifier = Notification.prevIDs[id]?.1
        }
        
        notification.title = message
        notification.informativeText = description
        
        notification.deliveryDate = scheduledTime
        
        if let placeholder = self.replyPlaceholder{
            notification.hasReplyButton = true
            
            notification.responsePlaceholder = (placeholder.isEmpty ? nil : placeholder)
        }
        
        if self.actionButtonTitle != nil || self.closeButtonTitle != nil{
            notification.hasActionButton = true
            
            if let title = self.actionButtonTitle{
                notification.actionButtonTitle = title
            }
            
            if let title = self.closeButtonTitle{
                notification.otherButtonTitle = title
            }
        }
        
        if #available(macOS 10.10, *){
            if let actions = self.actions{
                for action in actions{
                    if notification.additionalActions == nil{
                        notification.additionalActions = []
                    }
                
                    notification.additionalActions?.append(.init(identifier: action.id, title: action.displayName))
                }
            }
        }
        
        notification.userInfo = userTag
        
        if (self.displayActionSelector ?? false) && actions != nil{
            // WARNING, private API, not safe for production
            notification.setValue(true, forKey: "_alwaysShowAlternateActionMenu")
        }
            
        notification.soundName = NSUserNotificationDefaultSoundName
        
        return notification.adding(image: self.icon)
    }
    
    ///Tryes to deliver a notification to the user, if it can't bedelivered `nil` is returned, otherwise it returns the notification as a `NSUserNotification` object.
    public func send() -> NSUserNotification?{
        /*if Recovery.status{
            Swift.print("Recovery mode is active, notification sending is disabled")
            return nil
        }*/
        
        let noti = create()
        
        if noti.deliveryDate != nil{
            NSUserNotificationCenter.default.scheduleNotification(noti)
        }else{
            NSUserNotificationCenter.default.deliver(noti)
        }
        
        return noti
    }
    
    /**This timer event handling function is used to prevent having unnecessary long lists of notifications*/
    @objc private func timer(_ sender: Any){
        if Notification.prevIDs.count == 0{
            Notification.timer.invalidate()
            Notification.timer = nil
            return
        }
        
        for i in Notification.prevIDs{
            let minutes = (Int(i.value.0.timeIntervalSinceNow) / 60) % 60
            if minutes >= 2{
                Notification.prevIDs[i.key] = nil
            }
        }
    }
    
    ///Returns a copy fo this notification but with the specified image added to it
    public func adding(icon: Image?) -> Self{
        let cpy = copy()
        cpy.icon = icon
        return cpy
    }
    
    ///Returns a copy the current notification but with a scheduleds time of delivery added
    public func adding(scheduledTime: Date?) -> Self{
        let cpy = copy()
        cpy.scheduledTime = scheduledTime
        return cpy
    }
    
    ///Return a copy of the current notification that adds an action button with the specified text to the notification
    public func adding(actionButtonTitled title: String?) -> Self{
        let cpy = copy()
        cpy.actionButtonTitle = title
        return cpy
    }
    
    ///Returns a copy of the current notification that adds a close button with the specified text to the notification
    public func adding(closeButtonTitled title: String?) -> Self{
        let cpy = copy()
        cpy.closeButtonTitle = title
        return cpy
    }
    
    ///Returns a copy of the current notification that adds a close button with the specified text to the notification
    ///
    ///     NOTE: An empty placeholder text will just display the Reply button.
    public func adding(replyButtonAndPlaceholderText text: String) -> Self{
        let cpy = copy()
        cpy.replyPlaceholder = text
        return cpy
    }
    
    public func adding(userTag: [String: String]) -> Self{
        let cpy = copy()
        cpy.userTag = userTag
        return cpy
    }
    
    ///Returns a copy of the current notification that allows spamming
    public func allowingSpam(_ value: Bool = true) -> Self{
        let cpy = copy()
        cpy.allowsSpam = value
        return cpy
    }
    
    ///Returns a copy of the current notification witht id randomization setted
    public func usingRandomID(_ value: Bool = true) -> Self{
        let cpy = copy()
        cpy.usesRandomizedID = value
        return cpy
    }
    
}

@available(macOS 10.10, *) public extension Notification{
    ///Adds a cutom extra action to the notification
    func add(action: Action){
        if self.actions == nil{
            self.actions = []
        }
        
        self.actions?.append(action)
    }
    
    ///Returns a copy fo this notification but with a custom extra action added to it
    func adding(action: Action) -> Self{
        let cpy = copy()
        cpy.add(action: action)
        return cpy
    }
    
    ///Adds a cutom extra action to the notification
    func addAction(id: String, displayName: String){
        self.add(action: .init(id: id, displayName: displayName))
    }
    
    ///Returns a copy fo this notification but with a custom extra action added to it
    func addingAction(id: String, displayName: String) -> Self{
        let cpy = copy()
        cpy.add(action: .init(id: id, displayName: displayName))
        return cpy
    }
    
    ///Sets if the shown notification should display a selector to chose an action
    ///
    ///     The nil case is considered the same as false.
    ///
    ///     Warning: Makes use of private OS API, might not be safe turning this on for production apps.
    func actionSelector(enabled value: Bool) -> Self{
        let cpy = copy()
        cpy.displayActionSelector = value
        return cpy
    }
}

#endif
