//
//  DBImageField+CoreDataProperties.swift
//  CerificatesTemplates
//
//  Created by Apple on 31/01/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import Foundation
import CoreData


extension DBImageField {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBImageField> {
        return NSFetchRequest<DBImageField>(entityName: "DBImageField");
    }

    @NSManaged public var heightInPixels: NSNumber?
    @NSManaged public var image: NSData?
    @NSManaged public var templateName: String?
    @NSManaged public var widthInPixels: NSNumber?
    @NSManaged public var x: NSNumber?
    @NSManaged public var y: NSNumber?
    @NSManaged public var certificate: DBCertificate?
    @NSManaged public var transcript: DBTranscript?

}
