/*
 TINUNotifications: A library to send notifications and alerts more easily within a macOS app.
 Copyright (C) 2021-2022 Pietro Caruso

 This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
import Foundation
import SwiftPackagesBase

///Basic interface for notifications and alerts used by this library, it could be also used for other objects that presents similar behaviour
public protocol Message: Codable, Equatable, Copying {
    associatedtype T
    associatedtype G
    var message: String { get }
    var description: String { get }
    var icon: Image? { get }
    func create() -> G
    func send() -> T
    //func justSend()
}

public extension Message{
    ///Default implementation for `justSend()`, this will just send the `Messange` object without any returns
    func justSend() {
        let _ = send()
    }
}
