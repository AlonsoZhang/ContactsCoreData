//
//  SW+CoreDataProperties.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/13.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Foundation
import CoreData


extension SW {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SW> {
        return NSFetchRequest<SW>(entityName: "SW")
    }

    @NSManaged public var chinesename: String?
    @NSManaged public var englishname: String?
    @NSManaged public var birthday: NSDate?
    @NSManaged public var photo: NSData?
    @NSManaged public var email: String?
    @NSManaged public var department: String?
    @NSManaged public var employeeid: String?
    @NSManaged public var photonumber: NSObject?
    @NSManaged public var shortnumber: NSObject?

}
