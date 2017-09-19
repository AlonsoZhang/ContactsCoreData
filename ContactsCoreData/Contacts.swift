//
//  Contacts.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/19.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Cocoa
import Contacts

class Contacts: NSObject {
    func setNewContact(contact:CNMutableContact,name:String,engname:String,phoneNum:String,shortNum:String){
        let index = name.index(name.startIndex, offsetBy: 1)
        contact.familyName = name.substring(to: index)
        contact.givenName = name.substring(from: index)
        contact.nickname = engname
        var mutablephonearray = [Any]()
        if phoneNum.characters.count > 0 {
            let phoneNumber = CNLabeledValue.init(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber.init(stringValue: phoneNum))
            mutablephonearray.append(phoneNumber)
        }
        if shortNum.characters.count > 0 {
            let shortNumber = CNLabeledValue.init(label: "短号", value: CNPhoneNumber.init(stringValue: shortNum))
            mutablephonearray.append(shortNumber)
        }
        contact.phoneNumbers = mutablephonearray as! Array
    }
}
