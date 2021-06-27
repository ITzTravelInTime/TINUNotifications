import Foundation

#if os(macOS)
import AppKit
import TINURecovery

public protocol TINUNotificationDescriptor{
    var id: String {get}
    var title: String {get}
    var description: String {get}
    var scheduledTime: Date? { get }
}

/**Class used to manage natifications, you can create an instance of it or use the provvided shared instance.*/
public final class TINUNotifications{
    
    internal init(counter: UInt64 = 0, prevIDs: [String : (Date, String)] = [:], timer: Timer? = nil) {
        self.counter = counter
        self.prevIDs = prevIDs
        self.timer = timer
    }
    
    /**Provvided shared instance of this class for general purpose usage, if you want to clean the notifications storage just re-initialize this.*/
    public static var shared = TINUNotifications()
    
    private let idPrefix: String = Bundle.main.bundleIdentifier! + "."
    
    private var counter: UInt64 = 0
    private var prevIDs: [String: (Date, String)] = [:]
    private var timer: Timer!
    
    ///Contains all the necessary information needed to create a basic notification
    public struct BaseDescriptor: TINUNotificationDescriptor, Equatable, Codable{
        
        public init(id: String, title: String, description: String, scheduledTime: Date? = nil) {
            self.id = id
            self.title = title
            self.description = description
            self.scheduledTime = scheduledTime
        }
        
        ///The Unique Identifier of the notification, which used to track it
        public var id: String
        
        ///The title of the notification
        public var title: String
        
        ///The 'informativeText' of the notification which is the text containing more details
        public var description: String
        
        ///The exact moment in  which the notification should be delivered
        public var scheduledTime: Date?
    }
    
    ///Contains all the necessary information needed to create a basic notification
    public struct AdvancedDescriptor: TINUNotificationDescriptor{
        
        public init(id: String, title: String, description: String, scheduledTime: Date? = nil, image: NSImage? = nil) {
            self.id = id
            self.title = title
            self.description = description
            self.scheduledTime = scheduledTime
            self.image = image
        }
        
        ///The Unique Identifier of the notification, which used to track it
        public var id: String
        
        ///The title of the notification
        public var title: String
        
        ///The 'informativeText' of the notification which is the text containing more details
        public var description: String
        
        ///The exact moment in  which the notification should be delivered
        public var scheduledTime: Date?
        
        ///Optional image for the notification, some notifications might need it to provvide more context for the user
        var image: NSImage?
    }
    
    /**
     Creates and sends new 'NSUserNotitfication'.

     - Parameter description: The required information about the notification to create.
        
     - Parameter allowSpam: Determinates if this notification can be spammed or not.
     
     - Returns: An 'NSUserNotification' Object, this is usefoul if a notification needs to be retired after being sent
     */
    
    public func send<T: TINUNotificationDescriptor>(notification noti: T, allowSpam: Bool = false) -> NSUserNotification? {
        
        if TINURecovery.isOn{
            Swift.print("Recovery mode is active, notification sending is disabled")
            return nil
        }
        
        let notification = NSUserNotification()
        
        if !prevIDs.keys.contains(noti.id){
            notification.identifier = idPrefix + noti.id + (allowSpam ? String(counter) : "")
            
            prevIDs[noti.id] = (Date(), notification.identifier!)
            
            counter += 1
            
            if timer == nil{
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TINUNotifications.timer(_:)), userInfo: nil, repeats: true)
            }
        }else{
            notification.identifier = prevIDs[noti.id]?.1
        }
        
        //notification.title = TextManager.getViewString(context: ref, stringID: id + "Title")!
        //notification.informativeText = TextManager.getViewString(context: ref, stringID: id)!
        
        //TODO: Implement Text Manager Dependancy
        notification.title = noti.title
        notification.informativeText = noti.description
        
        notification.deliveryDate = noti.scheduledTime
        
        notification.soundName = NSUserNotificationDefaultSoundName
        
        if let img = noti as? AdvancedDescriptor{
            notification.contentImage = img.image
        }
        
        if notification.deliveryDate != nil{
            NSUserNotificationCenter.default.scheduleNotification(notification)
        }else{
            NSUserNotificationCenter.default.deliver(notification)
        }
        
        return notification
    }
    
    /**
     Creates and sends new 'NSUserNotitfication', without return it.

     - Parameter description: The required information about the notification to create.
        
     - Parameter allowSpam: Determinates if this notification can be spammed or not.
     */
    public func justSend<T: TINUNotificationDescriptor>(notification noti: T, allowSpam: Bool = false){
        let _ = send(notification: noti, allowSpam: allowSpam)
    }
    
    /**This timer event handling function is used to prevent having unnecessary long lists of notifications*/
    @objc private func timer(_ sender: Any){
        //Swift.print("Notifications timer schedules")
        for i in prevIDs{
            let minutes = (Int(i.value.0.timeIntervalSinceNow) / 60) % 60
            if minutes >= 2{
                prevIDs[i.key] = nil
            }
        }
    }
    
    deinit {
        timer.invalidate()
        timer = nil
        prevIDs.removeAll()
    }
}

#endif
