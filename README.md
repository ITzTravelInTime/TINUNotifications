# TINUNotifications
A library for easy, SwiftUI-like, usage of notifications and alerts on macOS.

## Features and usage

Notification: 
- Is codable so it can be serialised and de-serialised allowing you to store notifications in local files or create them directly from a web server.
- Can be used in a SwiftUI-like way or a more traditional way.
- Creates simple notitifications by using a `Notification` object and then sends it to the user, example usage:

```swift

import AppKit
import TINUNotifications

func deliverNotification(){
    guard let notification = Notification(id: "myFancyNotificationID", message: "Example notification", description: "This is an example notification, you can ignore it and go on with your work!").send() else { return }
    
    sleep(1)
    
    NSUserNotificationCenter.default.removeDeliveredNotification(notification)
}

deliverNotification()

```

Alert:
- Is codable so it can be serialised and de-serialised allowing you to store alerts in local files or create them directly from a web server.
- Can be used in a SwiftUI-like way or a more traditional way.
- Creates a simple alert to be displayed to the user. Example usage:

```swift

import AppKit
import TINUNotifications

func isEverithingOk() -> Bool{
    return Alert(message: "Are you ok?", description: "Tell me how are you. Is everything ok?").yesNo().send().yes()
}

print("Is the user ok? \(isEverithingOk() ? "Yes" : "No")")


```

## Who should use this Library?

This library should be used by swift apps/programs for macOS that needs to deal with notifications and alerts, by either having to serialize and deserialize those, or just needing a simple way to handling them.

This code is intended for macOS only since it requires the system library 'AppKit'.

## About the project

This code was created as part of my [TINU project](https://github.com/ITzTravelInTime/TINU) and it has been separated and made into it's own library to make the main project's source less complex and more focused on it's aim. 

Also having this as it's own library allows for code to be updated separately and so various versions of the main TINU app will be able to be compiled all with the latest version of this library.

## Used libraries
- [ITzTravelInTime/SwiftPackagesBase](https://github.com/ITzTravelInTime/SwiftPackagesBase)


## Credits

 - ITzTravelInTime (Pietro Caruso) - Project creator and main developer

## Contacts

 - ITzTravelInTime (Pietro Caruso): piecaruso97@gmail.com

## Legal info

TINUNotifications: A library to send notifications and alerts more easily within a macOS app.
Copyright (C) 2021-2022 Pietro Caruso

This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
