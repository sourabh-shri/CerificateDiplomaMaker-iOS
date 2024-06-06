//
//  DBTextView+CoreDataProperties.swift
//  CerificatesTemplates
//
//  Created by Apple on 31/01/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import Foundation
import CoreData


extension DBTextView {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBTextView> {
        return NSFetchRequest<DBTextView>(entityName: "DBTextView");
    }

    @NSManaged public var content: String?
    @NSManaged public var fontColorHex: String?
    @NSManaged public var fontFace: String?
    @NSManaged public var fontFamily: String?
    @NSManaged public var fontSize: Int32
    @NSManaged public var heightInPixels: Int32
    @NSManaged public var placeholder: String?
    @NSManaged public var templateName: String?
    @NSManaged public var widthInPixels: Int32
    @NSManaged public var x: Int32
    @NSManaged public var y: Int32
    @NSManaged public var certificate: DBCertificate?
    @NSManaged public var transcript: DBTranscript?

}
