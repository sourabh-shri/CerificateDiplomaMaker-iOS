//
//  DBTranscript+CoreDataProperties.swift
//  CerificatesTemplates
//
//  Created by Apple on 31/01/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import Foundation
import CoreData


extension DBTranscript {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBTranscript> {
        return NSFetchRequest<DBTranscript>(entityName: "DBTranscript");
    }

    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var organization: String?
    @NSManaged public var transcriptBgImageUrl: String?
    @NSManaged public var transcriptHeightInPixels: NSNumber?
    @NSManaged public var transcriptId: String?
    @NSManaged public var transcriptName: String?
    @NSManaged public var transcriptTitle: String?
    @NSManaged public var transcriptWidthInPixels: NSNumber?
    @NSManaged public var imageFilename: String?
    @NSManaged public var imageThumbFilename: String?
    @NSManaged public var imageFieldsTrans: NSSet?
    @NSManaged public var textFieldsTrans: NSSet?
    @NSManaged public var textViewsTrans: NSSet?

}

// MARK: Generated accessors for imageFieldsTrans
extension DBTranscript {

    @objc(addImageFieldsTransObject:)
    @NSManaged public func addToImageFieldsTrans(_ value: DBImageField)

    @objc(removeImageFieldsTransObject:)
    @NSManaged public func removeFromImageFieldsTrans(_ value: DBImageField)

    @objc(addImageFieldsTrans:)
    @NSManaged public func addToImageFieldsTrans(_ values: NSSet)

    @objc(removeImageFieldsTrans:)
    @NSManaged public func removeFromImageFieldsTrans(_ values: NSSet)

}

// MARK: Generated accessors for textFieldsTrans
extension DBTranscript {

    @objc(addTextFieldsTransObject:)
    @NSManaged public func addToTextFieldsTrans(_ value: DBTextField)

    @objc(removeTextFieldsTransObject:)
    @NSManaged public func removeFromTextFieldsTrans(_ value: DBTextField)

    @objc(addTextFieldsTrans:)
    @NSManaged public func addToTextFieldsTrans(_ values: NSSet)

    @objc(removeTextFieldsTrans:)
    @NSManaged public func removeFromTextFieldsTrans(_ values: NSSet)

}

// MARK: Generated accessors for textViewsTrans
extension DBTranscript {

    @objc(addTextViewsTransObject:)
    @NSManaged public func addToTextViewsTrans(_ value: DBTextView)

    @objc(removeTextViewsTransObject:)
    @NSManaged public func removeFromTextViewsTrans(_ value: DBTextView)

    @objc(addTextViewsTrans:)
    @NSManaged public func addToTextViewsTrans(_ values: NSSet)

    @objc(removeTextViewsTrans:)
    @NSManaged public func removeFromTextViewsTrans(_ values: NSSet)

}
