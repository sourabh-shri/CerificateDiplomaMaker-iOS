 //
//  AppDelegate.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/1/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit
import CoreData
import Photos

@UIApplicationMain
 
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Context.getInstance().setValue("1179092354", forKey: APPLE_APP_ID_KEY)
        Context.getInstance().setValue(Context.getInstance().getAppReviewURL(forAppId: "1179092354"), forKey: APP_REVIEW_URL_KEY)
        
#if PAID_APP
        Context.getInstance().setValue("1", forKey: PRO_VERSION_KEY)
        Context.getInstance().setValue("1179092372", forKey: APPLE_APP_ID_KEY) // App Id of PRO (Paid) app withOUT IAP
        Context.getInstance().setValue(Context.getInstance().getAppReviewURL(forAppId: "1179092372"), forKey: APP_REVIEW_URL_KEY)
    
#endif
        
        // Fetch Data from Certificate
        let fetchRequest3: NSFetchRequest<DBImageField> = DBImageField.fetchRequest()
        // Edit the entity name as appropriate.
        let entity3 = NSEntityDescription.entity(forEntityName: "DBImageField", in: managedObjectContext)
        fetchRequest3.entity = entity3
        do {
            let fetchObj3 = try managedObjectContext.fetch(fetchRequest3)
            for imgf in fetchObj3 {
                print(imgf.templateName ?? "name")
            }
        } catch{
            print(error.localizedDescription)
        }
        
        // test : fetch Data from Tf
        let fetchRequest: NSFetchRequest<DBTextField> = DBTextField.fetchRequest()
        
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "DBTextField", in: managedObjectContext)
        fetchRequest.entity = entity
        
        do {
            let fetchObj = try managedObjectContext.fetch(fetchRequest)
            for tf in fetchObj {
                print(tf.templateName ?? "None")
                print(tf.fontFace ?? "None")
            }
        } catch{
            print(error.localizedDescription)
        }
        
        // Fetch Data from Certificate 
        let fetchRequest2: NSFetchRequest<DBCertificate> = DBCertificate.fetchRequest()
        
        // Edit the entity name as appropriate.
        let entity2 = NSEntityDescription.entity(forEntityName: "DBCertificate", in: managedObjectContext)
        fetchRequest2.entity = entity2
        
        do {
            let fetchObj2 = try managedObjectContext.fetch(fetchRequest2)
            for cf in fetchObj2 {
                print(cf.certificateTitle ?? "Not Stored")
                print(cf.imageFields?.allObjects ?? "Not Stored")
                print(cf.textFields?.allObjects ?? "Not Stored")
                print(cf.textViews?.allObjects ?? "Not Stored")

            }
        } catch{
            print(error.localizedDescription)
        }
        
        /// fetch transcript data
        let fetchDataForTranscript: NSFetchRequest<DBTranscript> = DBTranscript.fetchRequest()
        let entityTrans = NSEntityDescription.entity(forEntityName: "DBTranscript", in: managedObjectContext)
        fetchDataForTranscript.entity = entityTrans
        do {
            let fetchObjTrans = try managedObjectContext.fetch(fetchDataForTranscript)
            for trans in fetchObjTrans {
                print(trans.transcriptTitle ?? "Not Stored")
                print(trans.imageFieldsTrans?.allObjects ?? "Not Stored")
                print(trans.textFieldsTrans?.allObjects ?? "Not Stored")
                print(trans.textViewsTrans?.allObjects ?? "Not Stored")
                
            }
        } catch{
            print(error.localizedDescription)
        }
        
        // Fetch Data from TextView
        let fetchRequest4: NSFetchRequest<DBTextView> = DBTextView.fetchRequest()
        
        // Edit the entity name as appropriate.
        let entity4 = NSEntityDescription.entity(forEntityName: "DBTextView", in: managedObjectContext)
        fetchRequest4.entity = entity4
        
        do {
            let fetchObj4 = try managedObjectContext.fetch(fetchRequest4)
            for cf in fetchObj4 {
                print(cf.templateName ?? "Not Stored")
                print(cf)
            }
        } catch{
            print(error.localizedDescription)
        }
        
        
        // MARK: First Time
        let defaults = UserDefaults.standard
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            //return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            defaults.set(1, forKey: "gradeCellCount")
            
            self.createPhotoLibraryAlbum(name: "Diploma")
            
            //return false
        }
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mobiona.CerificatesTemplates" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "TemplatesDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func showUpgradePopup(viewController: UIViewController) {
        let alertController = UIAlertController(
            title: "Upgrade to Pro Version to Continue",
            message: "This feature requires you to upgrade to Pro version!",
            preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(
            title: "Yes, Go Pro", style: UIAlertAction.Style.default) {
            (action) -> Void in
            // some action
            //viewController.dismiss(animated: true, completion: nil)
            let tVC = viewController.storyboard?.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
            //        self.presentViewController(tVC, animated: false, completion: nil)
            viewController.navigationController?.pushViewController(tVC, animated: true)
        }
        alertController.addAction(saveAction)
        
        let noAction = UIAlertAction(
            title: "No, Thanks", style: UIAlertAction.Style.default) {
            (action) -> Void in
            viewController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(noAction)
        
        let purchasedAction = UIAlertAction(
            title: "Already purchased?", style: UIAlertAction.Style.default) {
            (action) -> Void in
            // some action
            //viewController.dismiss(animated: true, completion: nil)
            let tVC = viewController.storyboard?.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
            // self.presentViewController(tVC, animated: false, completion: nil)
            viewController.navigationController?.pushViewController(tVC, animated: true)
        }
        alertController.addAction(purchasedAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Creating an custom album to store images
    func createPhotoLibraryAlbum(name: String) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    fatalError("Album placeholder is nil")
                }
                
                let defaults = UserDefaults.standard
                defaults.set("YES", forKey: "Authorization")
                
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album: PHAssetCollection = fetchResult.firstObject else {
                    // FetchResult has no PHAssetCollection
                    return
                }
                
                // Saved successfully!
                print(album.assetCollectionType)
            }
            else if error != nil {
                // Save album failed with error
                print(error?.localizedDescription as Any)
                
                let defaults = UserDefaults.standard
                defaults.set("NO", forKey: "Authorization")
            }
            else {
                // Save album failed with no error
            }
        })
    }

}
 extension UIImage {
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
 }

