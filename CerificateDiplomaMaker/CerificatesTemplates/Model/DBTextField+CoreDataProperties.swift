//
//  DBTextField+CoreDataProperties.swift
//  CerificatesTemplates
//
//  Created by Apple on 31/01/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import Foundation
import CoreData


extension DBTextField {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBTextField> {
        return NSFetchRequest<DBTextField>(entityName: "DBTextField");
    }

    @NSManaged public var content: String?
    @NSManaged public var fontColorHex: String?
    @NSManaged public var fontFace: String?
    @NSManaged public var fontFamily: String?
    @NSManaged public var fontSize: NSNumber?
    @NSManaged public var heightInPixels: NSNumber?
    @NSManaged public var placeholder: String?
    @NSManaged public var templateName: String?
    @NSManaged public var widthInPixels: NSNumber?
    @NSManaged public var x: NSNumber?
    @NSManaged public var y: NSNumber?
    @NSManaged public var certificate: DBCertificate?
    @NSManaged public var transcript: DBTranscript?

}
