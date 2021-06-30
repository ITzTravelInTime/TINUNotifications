# TINUNotifications
Library with the Basic, Notifications and Alerts, delivery and management system, used by TINU (https://github.com/ITzTravelInTime/TINU)

# Features description:

Notification: 
- Is codable so it can be serialised and de-serialised allowing you to store notifications in local files or create them directly from a web server.
- Creates simple notitifications by using a `Notification` object and then sends it to the user, example usage:

```swift

import AppKit
import TINUNotifications

func deliverNotification(){
    guard let notification = Notification(id: "myFancyNotificationID", messange: "Example notification", description: "This is an example notification, you can ignore it and go on with your work!").send() else { return }
    
    sleep(1)
    
    NSUserNotificationCenter.default.removeDeliveredNotification(notification)
}

deliverNotification()

```

Alert:
- Is codable so it can be serialised and de-serialised allowing you to store alerts in local files or create them directly from a web server.
- Creates a simple alert to be displayed to the user. Example usage:

```swift

import AppKit
import TINUNotifications

func isEverithingOk() -> Bool{
    return Alert(messange: "Are you ok?", description: "Tell me how are you. Is everything ok?").yesNo().send().yes()
}

print("Is the user ok? \(isEverithingOk() ? "Yes" : "No")")


```

# Who should use this Library?

This library should be used by swift apps/programs for macOS that needs to deliver some simple notifications and alerts to the user.

This code is intended for macOS only since it requires the system library 'AppKit'.

# About the project:

This code was created as part of my [TINU project](https://github.com/ITzTravelInTime/TINU) and it has been separated and made into it's own library to make the main project's source less complex and more focused on it's aim. 

Also having this as it's own library allows for code to be updated separately and so various versions of the main TINU app will be able to be compiled all with the latest version of this library.

# Credits:

ITzTravelInTime (Pietro Caruso) - Project creator
