//
//  File.swift
//  
//
//  Created by Pietro Caruso on 30/06/21.
//

import Foundation

#if os(macOS)
import AppKit
public typealias Image = NSImage
#else
import UIKit
public typealias Image = UIImage
#endif

