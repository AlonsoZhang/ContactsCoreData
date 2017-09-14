//
//  SW+CoreDataProperties.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/14.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Foundation
import CoreData


extension SW {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SW> {
        return NSFetchRequest<SW>(entityName: "SW")
    }

    @NSManaged public var birthday: TimeInterval
    @NSManaged public var chinesename: String?
    @NSManaged public var department: String?
    @NSManaged public var email: String?
    @NSManaged public var employeeid: String?
    @NSManaged public var englishname: String?
    @NSManaged public var photo: NSObject?
    @NSManaged public var photonumber: String?
    @NSManaged public var shortnumber: String?
    @NSManaged public var imessage: String?

}
