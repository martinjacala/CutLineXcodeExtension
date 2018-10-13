//
//  CutCommand.swift
//  CutLineXcodeExtension
//
//  Created by Martin Jacala on 12/10/2018.
//  Copyright © 2018 Martin Jacala. All rights reserved.
//

import Foundation
import XcodeKit

class CutCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        BetterCutUtils.doPasteboardOperation(.cut, with: invocation)
        completionHandler(nil)
    }
    
}
