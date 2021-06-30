import Foundation

#if os(macOS)
import AppKit
import TINURecovery

///Class that is used to create and send notifications
open class Notification: Messange{
    private init(id: String, message: String, description: String, imageData: Data? = nil, scheduledTime: Date? = nil, allowsSpam: Bool = false) {
        self.id = id
        self.message = message
        self.description = description
        self.imageData = imageData
        self.scheduledTime = scheduledTime
        self.allowsSpam = allowsSpam
    }
    
    public init(id: String, message: String, description: String, allowsSpam: Bool = false, icon: NSImage? = nil, scheduledTime: Date? = nil) {
        self.id = id
        self.message = message
        self.description = description
        self.icon = icon
        self.scheduledTime = scheduledTime
        self.allowsSpam = allowsSpam
    }
    
    ///Creates a copy of this notification as a new instance
    public func copy() -> Self {
        return Notification(id: id, message: message, description: description, imageData: imageData, scheduledTime: scheduledTime, allowsSpam: allowsSpam) as! Self
    }
    
    ///Used to make notifications app-specific/program-specific
    private static let idPrefix: String = (Bundle.main.bundleIdentifier ?? "TINUNotifications") + "."
    ///Counts the number of notifications to make the id unique for each one if needed
    private static var counter: UInt64 = 0
    ///Record of notifications ids and send times to have them delivered for not too much
    private static var prevIDs: [String: (Date, String)] = [:]
    ///Timer that undends notifications after 2 minutes
    private static var timer: Timer!
    
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
    
    ///Value used to determinate if this notification can be spammed or not
    public var allowsSpam: Bool = false
    
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
            notification.identifier = Notification.idPrefix + id + (allowsSpam ? String(Notification.counter) : "")
            
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
        
        notification.soundName = NSUserNotificationDefaultSoundName
        
        return notification.adding(image: self.icon)
    }
    
    ///Tryes to deliver a notification to the user, if it can't bedelivered `nil` is returned, otherwise it returns the notification as a `NSUserNotification` object.
    public func send() -> NSUserNotification?{
        if Recovery.status{
            Swift.print("Recovery mode is active, notification sending is disabled")
            return nil
        }
        
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
    
    ///Allows the current notification to be spammed when sent multiple times
    public func allowSpam(){
        self.allowsSpam = true
    }
    
    ///Adds an icon to this notification
    public func add(icon: Image?){
        self.icon = icon
    }
    
    ///Adds a scheduled time at which the notificastion should be delivered once sent
    public func add(scheduledTime: Date?){
        self.scheduledTime = scheduledTime
    }
    
    ///Returns a copy fo this notification but with the specified image added to it
    public func adding(icon: Image?) -> Notification{
        let cpy = copy()
        cpy.add(icon: icon)
        return cpy
    }
    
    ///Returns a copy the current notification but with a scheduleds time of delivery added
    public func adding(scheduledTime: Date?) -> Notification{
        let cpy = copy()
        cpy.add(scheduledTime: scheduledTime)
        return cpy
    }
    
    ///Returns a copy of the current notification that allows spamming
    public func allowingSpam() -> Notification{
        let cpy = copy()
        cpy.allowSpam()
        return cpy
    }
    
}

#endif
