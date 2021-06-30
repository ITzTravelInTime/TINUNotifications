//
//  File.swift
//  
//
//  Created by Pietro Caruso on 30/06/21.
//

import Foundation
import TINURecovery

///Basic interface for notifications and alerts used by this library, it could be also used for other objects that presents similar behaviour
public protocol Messange: Codable, Copying {
    associatedtype T
    associatedtype G
    var message: String { get }
    var description: String { get }
    var icon: Image? { get }
    func create() -> G
    func send() -> T
    func justSend()
}
