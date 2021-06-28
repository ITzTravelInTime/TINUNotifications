    import XCTest
    import AppKit
    @testable import TINUNotifications

    final class TINUNotificationsTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            //XCTAssertEqual(TINUNotifications().text, "Hello, World!")
            
            guard let notification = TINUNotifications.shared.send(notification: TINUNotifications.BaseDescriptor(id: "myFancyNotificationID", title: "Example notification", description: "This is an example notification, you can ignore it and go on with your work!", allowsSpam: true)) else { return }
            
            XCTAssert(notification.isPresented)
            
            NSUserNotificationCenter.default.removeDeliveredNotification(notification)
        }
    }
