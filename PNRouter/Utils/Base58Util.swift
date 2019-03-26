//
//  Base58Util.swift
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/27.
//  Copyright © 2018 旷自辉. All rights reserved.
//

import UIKit

class Base58Util: NSObject {

   static func Base58Encode(codeName:String) -> String {
        let codeData = codeName.data(using: String.Encoding.utf8);
        return  Base58.encode(codeData!)
    }
    
   static func Base58Decode(codeName:String) -> String {
        let codeData = Base58.decode(codeName)
        return String(data: codeData!, encoding: String.Encoding.utf8) ?? ""
//        var codeData = Data()
//        do {
//            //要做一些操作
//            codeData = try Base58.decode(codeName) ?? codeData
//            //要尝试做的事情
//        } catch let err as NSError {
//            //如果失败则进入catch代码块err.description
//            print(err.description)
//        }
//        let decodeStr = String(data: codeData, encoding: String.Encoding.utf8) ?? ""
//        return decodeStr
    }
    
    static func Base58EncodeDataToStr(data:Data) -> String {
        return  Base58.encode(data)
    }
    
    static func Base58DecodeStrToData(str:String) -> Data? {
        let codeData = Base58.decode(str)
        return codeData ?? nil
        
    }
}
