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

    }
    
    static func Base58EncodeDataToStr(data:Data) -> String {
        return  Base58.encode(data)
    }
    
    static func Base58DecodeStrToData(str:String) -> Data? {
        let codeData = Base58.decode(str)
        return codeData ?? nil
        
    }
}
