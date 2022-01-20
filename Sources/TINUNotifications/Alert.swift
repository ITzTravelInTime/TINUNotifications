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

///This objects represents an alert messange displayed to the user
public struct Alert: Message{
    
    ///This structure is used to represent the alert's buttons
    public struct Button: Equatable, Codable {
        ///The text for the alert's button
        public var text: String
        ///The key that should be pressed on the keyboard to trigger the click of this button
        public var keyEquivalent: String?
        
        public init(text: String, keyEquivalent: String? = nil){
            self.text = text
            self.keyEquivalent = keyEquivalent
        }
    }
    
    ///This enum is used as a `Codable` version of `NSAlert.Style`
    public enum Style : UInt8, Codable, Equatable, CaseIterable, RawRepresentable {
        ///Style of alert with the warning triangle
        case warning = 0
        ///Normal stlye of alert
        case informational = 1
        ///Style of alert with the red stop sign
        case critical = 2
        
        ///Returns the matching `NSAlert.Style` from this instance
        func convertToAlertStyle() -> NSAlert.Style{
            //we could have used raw values here, but this is more safe because wraw values could be changed breaking the code
            switch self {
            case .warning:
                return NSAlert.Style.warning
            case .critical:
                return NSAlert.Style.critical
            default:
                return NSAlert.Style.informational
            }
        }
        
        public init(from: NSAlert.Style) {
            switch from {
            case .warning:
                self = .warning
                break
            case .critical:
                self = .critical
                break
            default:
                self = .informational
                break
            }
        }
    }
    
    ///This is the window to be used when  the funtion `justSend` with a completition handler specified is called and the property `displayOnWindow` is true
    public static var window: NSWindow? = nil
    
    ///The title for for the alert
    public var message: String
    ///The text description of the alert
    public var description: String
    ///The style of the alert, see `Alert.Style` for more info
    public var style: Style = .informational
    ///The data that represents the icon of the alert
    private var imageData: Data? = nil
    ///The buttons for the alert, see `Alert.Button` for more info
    public var buttons: [Button] = []
    ///This property determinates if the alert should be displayed as a sheet on the window specified in the `Alert.window` static property
    public var displayOnWindow: Bool = false
    
    private init(message: String, description: String, style: Alert.Style = .informational, imageData: Data? = nil, buttons: [Alert.Button] = [], displayOnWindow: Bool = false) {
        self.message = message
        self.description = description
        self.style = style
        self.imageData = imageData
        self.buttons = buttons
        self.displayOnWindow = displayOnWindow
    }
    
    public init(message: String, description: String, style: Alert.Style = .informational, icon: Image? = nil, buttons: [Alert.Button] = [], displayOnWindow: Bool = false) {
        self.message = message
        self.description = description
        self.style = style
        self.icon = icon
        self.buttons = buttons
        self.displayOnWindow = displayOnWindow
    }
    
    /*
    public init(title: String, description: String, style: NSAlert.Style = .informational, icon: Image? = nil, buttons: [Alert.Button] = [], displayOnWindow: Bool = false) {
        self.message = title
        self.description = description
        self.style = .init(from: style)
        self.icon = icon
        self.buttons = buttons
        self.displayOnWindow = displayOnWindow
    }*/
    
    ///Creates anoter instance of `Alert` identical to the current one.
    public func copy() -> Alert {
        return Alert(message: message, description: description, style: style, imageData: imageData, buttons: buttons, displayOnWindow: true)
    }
    
    ///The icon to be used on the alert messange, if nil is specified, the app's icon will be used
    public var icon: Image?{
        get{
            guard let dat = imageData else { return nil }
            return Image(data: dat)
        }
        set{
            imageData = newValue?.tiffRepresentation
        }
    }
    
    ///Creates an `NSAlert` from this `Alert` istance
    public func create() -> NSAlert {
        let dialog = NSAlert()
        dialog.messageText = message
        dialog.informativeText = description
        dialog.alertStyle = style.convertToAlertStyle()
        dialog.icon = icon
        
        for i in 0..<buttons.count  {
            dialog.addButton(withTitle: buttons[i].text)
            guard let eq = buttons[i].keyEquivalent else {continue}
            dialog.buttons[i].keyEquivalent = eq
        }
        
        return dialog
    }
    
    ///Displays an `NSAlert` created from the current instance as modal and then return the `NSApplication.ModalResponse`
    public func send() -> NSApplication.ModalResponse {
        return create().runModal()
    }
    
    /**
     Creates an `NSAlert` from the current instance and dislays it as sheet on the windows specified in `Alert.window` if possible.
        
        - Parameter completionHandler: The handler that takes care of what happens after the user click on one of the alert's buttons.
     
     */
    public func justSendSheet(completionHandler handler: ((NSApplication.ModalResponse) -> Void)? = nil){
        DispatchQueue.main.async {
            if let win = Alert.window, self.displayOnWindow{
                create().beginSheetModal(for: win, completionHandler: { res in
                    guard let han = handler else { return }
                    han(res)
                })
            }else{
                guard let han = handler else { let _ = send(); return }
                han(send())
            }
        }
    }
    
    /**
     Creates an `NSAlert` from the current instance and dislays it as modal
     */
    public func justSend() {
        justSendSheet()
    }
    
    ///Creates a new instance of `Alert` equal to the current one except for the value of `style` which is now setted to `Alert.Style.warning`
    public func warning() -> Alert{
        var mycopy = copy()
        mycopy.style = .warning
        return mycopy
    }
    
    ///Creates a new instance of `Alert` equal to the current one except for the value of `style` which is now setted to `Alert.Style.critical`
    public func critical() -> Alert{
        var mycopy = copy()
        mycopy.style = .critical
        return mycopy
    }
    
    public static var localisedYesButoonTitle: String = "Yes"
    public static var localisedNoButoonTitle: String = "No"
    
    ///Creates a new instance of `Alert` equal to the current but adds 2 buttons, one named "Yes" and the other named "No".
    public func yesNo() -> Alert{
        return addingButton(title: Alert.localisedYesButoonTitle, keyEquivalent: "\r").addingButton(title: Alert.localisedNoButoonTitle)
    }
    
    public static var localisedOkButoonTitle: String = "Ok"
    public static var localisedCancelButoonTitle: String = "Cancel"
    
    ///Creates a new instance of `Alert` equal to the current but adds 2 buttons, one named "Ok" and the other named "Cancel".
    public func okCancel() -> Alert{
        return addingButton(title: Alert.localisedOkButoonTitle, keyEquivalent: "\r").addingButton(title: Alert.localisedCancelButoonTitle)
    }
    
    ///Adds a new button the alert
    public mutating func add(button: Button){
        buttons.append(button)
    }
    
    ///Adds a new button to the alter creating it from a specified text and keyEquivalent
    public mutating func addButton(title: String, keyEquivalent: String? = nil){
        add(button: Button(text: title, keyEquivalent: keyEquivalent))
    }
    
    ///Creates a new instance of `Alert` equal to the current one but using the specified icon
    public func adding(icon: NSImage?) -> Alert{
        var mycopy = copy()
        mycopy.icon = icon
        return mycopy
    }
    
    ///Creates a new instance of `Alert` equal to the current one but with the cpefied button added to it
    public func adding(button: Button) -> Alert{
        var mycopy = copy()
        mycopy.add(button: button)
        return mycopy
    }
    
    ///Creates a new instance of `Alert` equal to the current one but with the cpefied button (created using a name and a key equivalent)  added to it
    public func addingButton(title: String, keyEquivalent: String? = nil) -> Alert{
        var mycopy = copy()
        mycopy.addButton(title: title, keyEquivalent: keyEquivalent)
        return mycopy
    }
    
    ///Creates a new instance of `Alert` equal to the current one but that displays as a sheet on a windows if it's possible
    public func displayingOnWindow() -> Alert{
        var mycopy = copy()
        mycopy.displayOnWindow = true
        return mycopy
    }
    
}

#endif
