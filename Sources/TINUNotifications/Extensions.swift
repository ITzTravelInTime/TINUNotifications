//
//  File.swift
//  
//
//  Created by Pietro Caruso on 30/06/21.
//

import Foundation


public extension Messange{
    ///Default implementation for `justSend()`, this will just send the `Messange` object witouth any returns
    func justSend() {
        let _ = send()
    }
}

#if os(macOS)

import AppKit

public extension NSUserNotification{
    ///Adds an image to the current notification
    func add(image: NSImage?){
        self.contentImage = image
    }
    
    ///Returns a copy of this noritification with an immage added to it
    func adding(image: NSImage?) -> NSUserNotification{
        let cp = copy() as! NSUserNotification
        cp.add(image: image)
        return cp
    }
}

public extension NSApplication.ModalResponse{
    ///Detects if the fitst button was pressed
    func isFirstButton() -> Bool{
        return self == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    ///Detects if the second button was pressed
    func isSecondButton() -> Bool{
        return self == NSApplication.ModalResponse.alertSecondButtonReturn
    }
    
    ///Detects if the third button was pressed
    func isThirdButton() -> Bool{
        return self == NSApplication.ModalResponse.alertThirdButtonReturn
    }
    
    ///Detects if not the first, the second or the third button was pressed
    func isAnotherButton() -> Bool{
        return !(isFirstButton() || isSecondButton() || isThirdButton())
    }
    
    ///Detects if the fitst button was pressed
    func ok() -> Bool{
        return isFirstButton()
    }
    
    ///Detects if not the first button was pressed
    func notOk() -> Bool{
        return !isFirstButton()
    }
    
    ///Detects if the fitst button was pressed
    func yes() -> Bool{
        return isFirstButton()
    }
    
    ///Detects if not the first button was pressed
    func cancel() -> Bool{
        return !isFirstButton()
    }
}

#endif
