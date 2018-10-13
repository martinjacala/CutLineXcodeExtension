//
//  BetterCutUtils.swift
//  CutLineXcodeExtension
//
//  Created by Martin Jacala on 13/10/2018.
//  Copyright © 2018 Martin Jacala. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

enum PasteboardOperation {
    case cut
    case copy
}

class BetterCutUtils {
    
    static func doPasteboardOperation(_ operation: PasteboardOperation, with invocation: XCSourceEditorCommandInvocation) {
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            return
        }
        
        if selection.start.line == selection.end.line && selection.start.column == selection.end.column {
            // No selection
            let currentLine = invocation.buffer.lines[selection.start.line] as! String
            let lineSelection = XCSourceTextRange(start: XCSourceTextPosition(line: selection.start.line, column: 0),
                                                  end: XCSourceTextPosition(line: selection.start.line, column: currentLine.count - 1))
            processLines(with: invocation, selection: lineSelection, operation: operation)
        } else {
            // Something is selected
            processLines(with: invocation, selection: selection, operation: operation)
        }
    }
    
    static func processLines(with invocation: XCSourceEditorCommandInvocation, selection: XCSourceTextRange, operation: PasteboardOperation) {
        var textToPasteboard = ""
        
        var removeLines = [Int]()
        for lineIndex in selection.start.line...selection.end.line {
            guard lineIndex < invocation.buffer.lines.count else { break }
            
            var line = invocation.buffer.lines[lineIndex] as! String
            
            var startIndex = line.startIndex
            var endIndex = line.endIndex
            
            if lineIndex == selection.start.line {
                startIndex = line.index(line.startIndex, offsetBy: selection.start.column)
            }
            if lineIndex == selection.end.line {
                endIndex = line.index(line.startIndex, offsetBy: selection.end.column)
            }
            
            textToPasteboard = textToPasteboard + line[startIndex..<endIndex]
            
            if operation == .cut {
                line.removeSubrange(startIndex..<endIndex)
                
                invocation.buffer.lines.replaceObject(at: lineIndex, with: line)
                if line.trimmingCharacters(in: CharacterSet.newlines).isEmpty {
                    removeLines.append(lineIndex)
                }
            }
        }
        
        if operation == .cut {
            invocation.buffer.lines.removeObjects(at: IndexSet(removeLines))
        }
        
        invocation.buffer.selections.setArray([XCSourceTextRange(start: XCSourceTextPosition(line: selection.start.line, column: selection.start.column), end: XCSourceTextPosition(line: selection.start.line, column: selection.start.column))])
        
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(textToPasteboard, forType: .string)
    }
    
}
