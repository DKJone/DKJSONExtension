//  SourceEditorExtension.swift
//  JSONExtension
//  Created by ___ORGANIZATIONNAME___ on 2021/4/23
//
//
//
//                    ██████╗ ██╗  ██╗     ██╗ ██████╗ ███╗   ██╗███████╗
//                    ██╔══██╗██║ ██╔╝     ██║██╔═══██╗████╗  ██║██╔════╝
//                    ██║  ██║█████╔╝      ██║██║   ██║██╔██╗ ██║█████╗
//                    ██║  ██║██╔═██╗ ██   ██║██║   ██║██║╚██╗██║██╔══╝
//                    ██████╔╝██║  ██╗╚█████╔╝╚██████╔╝██║ ╚████║███████╗
//                    ╚═════╝ ╚═╝  ╚═╝ ╚════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝
//
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [[.nameKey: "将JSON文件转化模型", .identifierKey: "paraseFile", .classNameKey: SourceEditorCommand.className()],
                [.nameKey: "从剪贴板获取JSON转化为模型", .identifierKey: "parasePasteboard", .classNameKey: SourceEditorCommand.className()]]
    }
}
