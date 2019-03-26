//
//  KeyChainUitl.swift
//  Qlink
//
//  Created by 旷自辉 on 2018/4/3.
//  Copyright © 2018年 pan. All rights reserved.
//

import Foundation
import KeychainAccess


class KeychainUtil: NSObject {
    
private static let KeyService : String = "com.winq.routerchat"
    // 清除指定key
    @objc static func removeKey(keyName key:String) -> Bool {
        let keychain = Keychain(service:KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            try keychain
                 .remove(key)
        } catch _ {
            return false
        }
        
        return true
    }
    
    // 清除所有key
   @objc static func removeAllKey() -> Bool {
        let keychain = Keychain(service:KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            try keychain
                .removeAll()
        } catch _ {
            return false
        }
        
        return true
    }
    
    
   @objc static func isExistKey(keyName key:String) -> Bool {
        
        let keychain = Keychain(service:KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            let keyValue : String = try keychain
                .get(key)!
            if keyValue.isEmpty {
                return false
            }
        } catch _ {
            return false
        }
        
        return true
        
    }
    
    @objc static func getKeyValue(keyName key:String) -> String {
        
        let keychain = Keychain(service:KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            let keyValue  = try keychain
                .get(key)
            if keyValue == nil {
                return ""
            }
            return keyValue!
        } catch _ {
            return ""
        }
    }
    
    @objc static func getKeyDataValue(keyName key:String) -> Data? {
        
        let keychain = Keychain(service:KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            let keyValue :Data? = (try keychain
                .getData(key))
            return keyValue
        } catch _ {
            return nil
        }
    }
    
   @objc static func saveValueToKey(keyName key:String, keyValue value:String) -> Bool {
        
        let keychain = Keychain(service: KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            try keychain
                .accessibility(.whenUnlockedThisDeviceOnly)
                .set(value, key: key)
        } catch _ {
            return false
        }
        
        return true
    }
    
    @objc static func saveDataKeyAndData(keyName key:String, keyValue value:Data) -> Bool {
        
        let keychain = Keychain(service: KeychainUtil.KeyService)
        do {
            //save pirivate key to keychain
            try keychain
                .accessibility(.whenUnlockedThisDeviceOnly)
                .set(value, key: key)
        } catch _ {
            return false
        }
        return true
    }
    
    
}
