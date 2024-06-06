//
//  DBCertificate+CoreDataProperties.swift
//  CerificatesTemplates
//
//  Created by Apple on 31/01/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import Foundation
import CoreData


extension DBCertificate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCertificate> {
        return NSFetchRequest<DBCertificate>(entityName: "DBCertificate");
    }

    @NSManaged public var certificateTitle: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var organization: String?
    @NSManaged public var templateBgImageUrl: String?
    @NSManaged public var templateHeightInPixels: NSNumber?
    @NSManaged public var templateId: String?
    @NSManaged public var templateName: String?
    @NSManaged public var templateWidthInPixels: NSNumber?
    @NSManaged public var imageFilename: String?
    @NSManaged public var imageThumbFilename: String?
    @NSManaged public var imageFields: NSSet?
    @NSManaged public var textFields: NSSet?
    @NSManaged public var textViews: NSSet?

}

// MARK: Generated accessors for imageFields
extension DBCertificate {

    @objc(addImageFieldsObject:)
    @NSManaged public func addToImageFields(_ value: DBImageField)

    @objc(removeImageFieldsObject:)
    @NSManaged public func removeFromImageFields(_ value: DBImageField)

    @objc(addImageFields:)
    @NSManaged public func addToImageFields(_ values: NSSet)

    @objc(removeImageFields:)
    @NSManaged public func removeFromImageFields(_ values: NSSet)

}

// MARK: Generated accessors for textFields
extension DBCertificate {

    @objc(addTextFieldsObject:)
    @NSManaged public func addToTextFields(_ value: DBTextField)

    @objc(removeTextFieldsObject:)
    @NSManaged public func removeFromTextFields(_ value: DBTextField)

    @objc(addTextFields:)
    @NSManaged public func addToTextFields(_ values: NSSet)

    @objc(removeTextFields:)
    @NSManaged public func removeFromTextFields(_ values: NSSet)

}

// MARK: Generated accessors for textViews
extension DBCertificate {

    @objc(addTextViewsObject:)
    @NSManaged public func addToTextViews(_ value: DBTextView)

    @objc(removeTextViewsObject:)
    @NSManaged public func removeFromTextViews(_ value: DBTextView)

    @objc(addTextViews:)
    @NSManaged public func addToTextViews(_ values: NSSet)

    @objc(removeTextViews:)
    @NSManaged public func removeFromTextViews(_ values: NSSet)

}
