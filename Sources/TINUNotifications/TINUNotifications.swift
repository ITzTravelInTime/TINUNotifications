import Foundation

#if os(macOS)
import AppKit
import TINURecovery

public protocol TINUNotificationDescriptor{
    var id: String {get}
    var title: String {get}
    var description: String {get}
    var scheduledTime: Date? { get }
    var allowsSpam: Bool { get }
    func send() -> NSUserNotification?
    func justSend()
}

extension TINUNotificationDescriptor{
    /**
     Creates and sends new 'NSUserNotitfication' from the current instance and then returns it
     
     DO NOT OVERRIDE THIS FUNCTION
     */
    public func send() -> NSUserNotification?{
        return TINUNotifications.shared.send(notification: self)
    }
    
    /**
     Creates and sends new 'NSUserNotitfication' from the current instance
     
     DO NOT OVERRIDE THIS FUNCTION
     */
    public func justSend() {
        return TINUNotifications.shared.justSend(notification: self)
    }
}

/**Class used to manage user natifications, you can create an instance or subclass of it or use the provvided shared instance.*/
open class TINUNotifications{
    
    ///Public initializyer, to let the library user create subclasses and instances of this class
    public init() {
        self.counter = 0
        self.prevIDs = [:]
        self.timer = nil
    }
    
    /**Provvided shared instance of this class for general purpose usage, if you want to clean the notifications storage just re-initialize this.*/
    public static var shared = TINUNotifications()
    
    //Used to make notifications app-specific/program-specific
    private let idPrefix: String = (Bundle.main.bundleIdentifier ?? "TINUNotifications") + "."
    
    private var counter: UInt64 = 0
    private var prevIDs: [String: (Date, String)] = [:]
    private var timer: Timer!
    
    ///Contains all the necessary information needed to create a basic notification
    public struct BaseDescriptor: TINUNotificationDescriptor, Equatable, Codable{
        
        public init(id: String, title: String, description: String, allowsSpam: Bool = false, scheduledTime: Date? = nil) {
            self.id = id
            self.title = title
            self.description = description
            self.allowsSpam = allowsSpam
            self.scheduledTime = scheduledTime
        }
        
        ///The Unique Identifier of the notification, which used to track it
        public var id: String
        
        ///The title of the notification
        public var title: String
        
        ///The 'informativeText' of the notification which is the text containing more details
        public var description: String
        
        ///Determinates if the system to avoid notification spamming should be used or not
        public var allowsSpam: Bool = false
        
        ///The exact moment in  which the notification should be delivered
        public var scheduledTime: Date?
    }
    
    ///Contains all the necessary information needed to create a basic notification
    public struct AdvancedDescriptor: TINUNotificationDescriptor{
        
        public init(id: String, title: String, description: String, allowsSpam: Bool = false, scheduledTime: Date? = nil, image: NSImage? = nil) {
            self.id = id
            self.title = title
            self.description = description
            self.allowsSpam = allowsSpam
            self.scheduledTime = scheduledTime
            self.image = image
        }
        
        ///The Unique Identifier of the notification, which used to track it
        public var id: String
        
        ///The title of the notification
        public var title: String
        
        ///The 'informativeText' of the notification which is the text containing more details
        public var description: String
        
        ///Determinates if the system to avoid notification spamming should be used or not
        public var allowsSpam: Bool = false
        
        ///The exact moment in  which the notification should be delivered
        public var scheduledTime: Date?
        
        ///Optional image for the notification, some notifications might need it to provvide more context for the user
        var image: NSImage?
    }
    
    /**
     Creates and sends new 'NSUserNotitfication'.

     - Parameter noti: The required information about the notification to create.
     
     - Returns: An 'NSUserNotification' Object, this is usefoul if a notification needs to be retired after being sent
     */
    
    open func send<T: TINUNotificationDescriptor>(notification noti: T) -> NSUserNotification? {
        
        if Recovery.status{
            Swift.print("Recovery mode is active, notification sending is disabled")
            return nil
        }
        
        let notification = NSUserNotification()
        
        if !prevIDs.keys.contains(noti.id){
            notification.identifier = idPrefix + noti.id + (noti.allowsSpam ? String(counter) : "")
            
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

     - Parameter noti: The required information about the notification to create.
     */
    open func justSend<T: TINUNotificationDescriptor>(notification noti: T){
        let _ = send(notification: noti)
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
