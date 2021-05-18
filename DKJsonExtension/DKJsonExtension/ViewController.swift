//  ViewController.swift
//  
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

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var codeableBtn: NSButton!
    @IBOutlet weak var handyJSONBtn: NSButton!
    @IBOutlet weak var swiftyJSONBtn: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        [codeableBtn,handyJSONBtn,swiftyJSONBtn].forEach {
            $0?.state = UserDefaults.modelType == $0?.title ? .on : .off
        }
        for i in 0..<3 {
            let btn = self.view.viewWithTag(100 + i) as? NSButton
            btn?.state = UserDefaults.modelStyle == btn?.title ?.on:.off
        }
    }


    @IBAction func modeTypeChange(_ sender: NSButton) {
        [codeableBtn,handyJSONBtn,swiftyJSONBtn].forEach {
            $0?.state = sender.title == $0?.title ? .on : .off
        }
        UserDefaults.modelType = sender.title
        
    }

    @IBAction func modeNameStyleChange(_ sender: NSButton) {
        for i in 0..<3 {
            let btn = self.view.viewWithTag(100 + i) as? NSButton
            btn?.state = sender.title == btn?.title ?.on:.off
        }
        UserDefaults.modelStyle = sender.title

    }

}



extension UserDefaults{

    static var grouped:UserDefaults{
        return UserDefaults(suiteName: "group.com.dkjone.DKJsonExtension") ?? standard
    }
    /// 模型类型
    static var  modelType: String {
        get { return grouped.string(forKey: #function) ?? "HandyJSON" }
        set { grouped.setValue(newValue, forKey: #function) }
    }
    // 命名规则
    static var modelStyle: String {
        get { return grouped.string(forKey: #function) ?? "驼峰法" }
        set { grouped.setValue(newValue, forKey: #function) }
    }
}
