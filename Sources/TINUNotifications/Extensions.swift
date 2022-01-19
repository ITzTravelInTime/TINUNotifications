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
