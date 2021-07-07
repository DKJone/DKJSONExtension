//  SourceEditorCommand.swift
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

import AppKit
import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        print(UserDefaults.modelStyle)
        print(UserDefaults.modelType)
        var allStr = invocation.buffer.lines.compactMap { $0 as? String }.joined()
        if invocation.commandIdentifier == "parasePasteboard" {
            allStr = NSPasteboard.general.string(forType: .string) ?? ""
        }

        if let data = allStr.data(using: String.Encoding.utf8), let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
            var newLines = """
            //      DKJSONFormate File
            //
            //                    ██████╗ ██╗  ██╗     ██╗ ██████╗ ███╗   ██╗███████╗
            //                    ██╔══██╗██║ ██╔╝     ██║██╔═══██╗████╗  ██║██╔════╝
            //                    ██║  ██║█████╔╝      ██║██║   ██║██╔██╗ ██║█████╗
            //                    ██║  ██║██╔═██╗ ██   ██║██║   ██║██║╚██╗██║██╔══╝
            //                    ██████╔╝██║  ██╗╚█████╔╝╚██████╔╝██║ ╚████║███████╗
            //                    ╚═════╝ ╚═╝  ╚═╝ ╚════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝
            //

            """
            if invocation.commandIdentifier == "parasePasteboard" {
               newLines = ""
            }
            if UserDefaults.modelType == "HandyJSON" {
                newLines += "import HandyJSON \n\n" + paraseJSON(dic: JSON(dict))
            } else if UserDefaults.modelType == "Codable" {
                newLines += "\n\n" + paraseJSON(dic: JSON(dict))
            } else { // SwiftyJSON
                newLines += "import SwiftyJSON \n\n" + paraseJSON(dic: JSON(dict))
            }
            if invocation.commandIdentifier != "parasePasteboard" {
                invocation.buffer.lines.removeAllObjects()
            }
            newLines.enumerateLines { str, _ in
                invocation.buffer.lines.add(str)
            }
        } else {
            print("------\n not a json \n----------\n")
        }

//        invocation.buffer.lines.add("test - dkjone")
        completionHandler(nil)
    }

    /// 将JSON转化为模型类文件内容的字符串
    func paraseJSON(dic: JSON, fileName: String = "Model") -> String {
        let keys = dic.dictionaryValue.keys
        if keys.isEmpty { return "\n" }
        var structName = fileName
        if structName.isEmpty {
            structName = "NameLessModel"
        }

        var allText = "///<#模型\(fileName)#>\nstruct \(fileName)"
        if UserDefaults.modelType == "HandyJSON" {
            allText += ": HandyJSON{\n"
        } else if UserDefaults.modelType == "Codable" {
            allText += ": Codable{\n"
        } else {
            allText += "{\n"
        }

        /// 字段名映射[JSON原始名:修改后字段名]
        var maperedKeys = [String: String]()

        keys.forEach { key in
            let uppercaseKey = uppercaseFirstCharacter(originString: key)
            let lowcaseKey = lowcaseFirstCharacter(originString: key)
            if lowcaseKey != key { maperedKeys[key] = lowcaseKey }
            switch dic[key].type {
            case .number:
                allText += "var \(lowcaseKey) = \(dic[key].numberValue.description.contains(".") ? "0.0" : "0")\n"
            case .bool: allText += "var \(lowcaseKey) = false\n"
            case .null, .unknown, .string: allText += "var \(lowcaseKey) = \"\"\n"
            case .dictionary:
                allText += paraseJSON(dic: dic[key], fileName: uppercaseKey)
                allText += "var \(lowcaseKey) = \(uppercaseKey)()\n"
            case .array:
                if dic[key].arrayValue.isEmpty { allText += "var \(lowcaseKey) = [Any]()\n" } else {
                    switch dic[key, 0].type {
                    case .number: allText += "var \(lowcaseKey) = [\(dic[key, 0].numberValue.description.contains(".") ? "Float" : "Int")]()\n"
                    case .bool: allText += "var \(lowcaseKey) = [Bool]()\n"
                    case .null, .unknown, .string: allText += "var \(lowcaseKey) = [String]()\n"
                    case .dictionary:
                        allText += paraseJSON(dic: dic[key, 0], fileName: uppercaseKey)
                        allText += "var \(lowcaseKey) = [\(uppercaseKey)]()\n"
                    case .array: allText += "var \(lowcaseKey) = [Any]()\n"
                    }
                }
            }
        }
        if UserDefaults.modelType == "HandyJSON" {
            allText += "mutating func mapping(mapper: HelpingMapper) {\n"
            for (key, value) in maperedKeys {
                allText += "mapper <<< \(value) <-- \"\(key)\"\n"
            }
            allText += "}\n}\n"
        } else if UserDefaults.modelType == "Codable" {
            allText += "enum CodingKeys: String, CodingKey {\n"
            let keysStr = keys.filter { !maperedKeys.keys.contains($0) }.joined(separator: ",")
            allText += "case " + keysStr + "\n"
            for (key, value) in maperedKeys {
                allText += " case \(value) = \"\(key)\"\n"
            }
            allText += "}\n}\n"
        } else { // SwiftyJSON
            allText += "init(json:JSON) {\n"
            keys.forEach { key in
                let ivaName = maperedKeys.keys.contains(key) ? maperedKeys[key]! : key
                switch dic[key].type {
                case .number:
                    allText += "\(ivaName) = \(dic[key].numberValue.description.contains(".") ? "json[\"\(key)\"].floatValue" : "json[\"\(key)\"].intValue")\n"
                case .bool:
                    allText += "\(ivaName) = json[\"\(key)\"].boolValue\n"
                case .null, .unknown, .string:
                    allText += "\(ivaName) = json[\"\(key)\"].stringValue\n"
                case .dictionary:
                    allText += "\(ivaName) = \(uppercaseFirstCharacter(originString: key))(json:dic[\"\(key)\"])\n"
                case .array:
                    if dic[key].arrayValue.isEmpty { allText += "\(ivaName) = [Any]()\n" } else {
                        switch dic[key, 0].type {
                        case .number: allText += "\(ivaName) = \(dic[key].numberValue.description.contains(".") ? "json[\"\(key)\"].arrayValue.map{$0.floatValue}" : "json[\"\(key)\"].arrayValue.map{$0.intValue}")\n"
                        case .bool: allText += "\(ivaName) = dic[\"\(key)\"].arrayValue.map{$0.boolValue}\n"
                        case .null, .unknown, .string:
                            allText += "\(ivaName) = json[\"\(key)\"].arrayValue.map{$0.stringValue}\n"
                        case .dictionary:
                            allText += "\(ivaName) = dic[\"\(key)\"].arrayValue.map{\(uppercaseFirstCharacter(originString: key))(json:$0)}\n"
                        case .array: allText += "\(ivaName) = [Any]()\n"
                        }
                    }
                }
            }
            allText += "}\n}\n"
        }
        return allText
    }

    /// 首字母转大写去除`—`和`_`，用作类名、结构体名
    func uppercaseFirstCharacter(originString: String) -> String {
        var formatedString = originString

        (65 ... 90).map { String(Unicode.Scalar($0)) }.forEach { word in
            formatedString = formatedString.replacingOccurrences(of: word, with: "-\(word)")
        }
        if UserDefaults.modelStyle == "使用_分割" {
            formatedString = formatedString.lowercased().replacingOccurrences(of: "-", with: "_")
        } else if UserDefaults.modelStyle == "全部小写" {
            formatedString = formatedString.lowercased()
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: "_", with: "")
        } else if UserDefaults.modelStyle == "驼峰法" {
            formatedString = formatedString.capitalized
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: "_", with: "")
        }

        return formatedString
    }

    // 首字母转小写去除`-`和`_`，用作属性名
    func lowcaseFirstCharacter(originString: String) -> String {
        if originString.isEmpty { return "" }
        return uppercaseFirstCharacter(originString: originString).replacingCharacters(in: "S".startIndex ..< "S".endIndex, with: originString.first!.lowercased())
    }
}

extension UserDefaults {
    static var grouped: UserDefaults {
        return UserDefaults(suiteName: "group.com.dkjone.DKJsonExtension") ?? standard
    }

    /// 模型类型
    static var modelType: String {
        get { return grouped.string(forKey: #function) ?? "HandyJSON" }
        set { grouped.setValue(newValue, forKey: #function) }
    }

    // 命名规则
    static var modelStyle: String {
        get { return grouped.string(forKey: #function) ?? "驼峰法" }
        set { grouped.setValue(newValue, forKey: #function) }
    }
}
