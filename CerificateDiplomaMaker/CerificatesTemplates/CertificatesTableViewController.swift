//
//  CertificatesTableViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/8/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

//TranscriptTableViewController
class CertificatesTableViewController: UITableViewController,NSFetchedResultsControllerDelegate,MFMailComposeViewControllerDelegate {
    
    let managedObjContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var navDeleteBtn: UIBarButtonItem!
    
    let noCertImgView = UIImageView()
    
    var showDeleteBtn : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTableVIew()
    }    
    override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarBg.png"),                                                               for: .default)
        navigationItem.title = "MY Certificates"

        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(CertificatesTableViewController.Cancel))
        navigationItem.leftBarButtonItem = backItem
        showDeleteBtn = false
        navDeleteBtn.tintColor = UIColor.white
        tableView.reloadData()
        noCertImgView.image = UIImage(named:"No_Certificate_Dialog.png")
        noCertImgView.frame.size.width = UIScreen.main.bounds.size.width - 60
        noCertImgView.frame.origin.x = UIScreen.main.bounds.size.width/2 - noCertImgView.frame.size.width/2
        noCertImgView.frame.size.height = UIScreen.main.bounds.size.height/3
        noCertImgView.frame.origin.y = UIScreen.main.bounds.size.height/2 - noCertImgView.frame.size.height

        tableView.addSubview(noCertImgView)
        noCertImgView.isHidden = true
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        tableView.reloadData()
//    }

    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        if !showDeleteBtn {
            showDeleteBtn = true
            navDeleteBtn.tintColor = UIColor(red:234/255 , green:60/255 , blue:87/255 , alpha:0.67)
        }
        else {
            showDeleteBtn = false
            navDeleteBtn.tintColor = UIColor.white
        }
        self.tableView.reloadData()
    }
    
    @objc func Cancel(){
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func customizeTableVIew() {
        self.view.backgroundColor = UIColor.clear
        let bgImageView = UIImageView(image: UIImage(named: "bg.png"))
        bgImageView.frame = self.tableView.frame
        self.tableView.backgroundView = bgImageView
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        if sectionInfo.numberOfObjects == 0 {
            showDeleteBtn = false
            navDeleteBtn.tintColor = UIColor.white
            noCertImgView.isHidden = false
        }
        else {
            print(sectionInfo.numberOfObjects)
            noCertImgView.isHidden = true
        }
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            return 250
        }else {
            return 117
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CertificateCellID", for: indexPath) as! HomeTableViewCell
        cell.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
//        if cell == nil {
//            cell = HomeTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CertificateCellID")
//        }
        
        
        if (showDeleteBtn) {
            cell.deleteBtn.isSelected = true
        }
        else if (!showDeleteBtn) {
            cell.deleteBtn.isSelected = false
        }
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        cell.deleteBtn.tag = indexPath.row
        
        return cell
    }
    

    func configureCell(_ cell: HomeTableViewCell, atIndexPath indexPath: IndexPath) {

        let object = self.fetchedResultsController.object(at: indexPath)
        
        if let nameData = (object.value(forKey: "certificateTitle") as AnyObject).description {
            cell.nameLabel.text = nameData
        }
        
        if let degreeData = (object.value(forKey: "templateName") as AnyObject).description {
            cell.degreeLabel.text = degreeData
        }
        
        if let date = object.value(forKey: "dateCreated") as? Date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            let str = dateFormatter.string(from: date)
            cell.dateOfIssue.text = str
        }
        
        //if let  data:Data = object.value(forKey: "image") as? Data
        let fileName: String = object.value(forKey: "imageThumbFilename") as! String
        let fullFilePath: String = Context.getInstance().getImageStorageFullpath(forFilename: fileName)
        var data:Data? = nil
        do { data = try Data(contentsOf:URL.init(fileURLWithPath: fullFilePath)) } catch {}
        if data == nil { data = object.value(forKey: "image") as? Data }
        if data != nil
        {
            let dataImage = UIImage(data: data!, scale: 1)
            cell.imgView.image = dataImage
            /*
            let time1 = CACurrentMediaTime()
//            
//            DispatchQueue.global(qos: .background).async {
//                weak in
            
            
            
//                DispatchQueue.main.async {
//                    weak in
                    if (data?.count)!/1024/1024 < 2 {
                        let dataImage = UIImage(data: data!, scale: 0.1)
                        cell.imgView.image = dataImage
                    }
                    else {
                        let myPicture = UIImage(data:data!)!
                        let myThumb2 = myPicture.resizeWith(percentage: 0.1)//resizeWith(width: 372.0)
                        cell.imgView.image = myThumb2
                    }
//                }
//            }
            
            
            print(CACurrentMediaTime() - time1)
            */
        }
        
    }
    
    @IBAction func deleteFromDB(_ sender: UIButton) {
        
        let point = tableView.convert(CGPoint.zero, from: sender)
        let indexPath = tableView.indexPathForRow(at: point)

        let currentCell = tableView.cellForRow(at: indexPath!) as! HomeTableViewCell
        
        if currentCell.deleteBtn.isSelected {
            let alertController = UIAlertController(
                title: "Confirm Deletion",
                message: "Are you sure you want to delete the certificate?",
                preferredStyle: UIAlertController.Style.alert)
            
            let yesAction = UIAlertAction(
                title: "Yes! Delete", style: UIAlertAction.Style.default) {
                (action) -> Void in
                let context = self.fetchedResultsController.managedObjectContext
                context.delete(self.fetchedResultsController.object(at: indexPath!) as NSManagedObject)
                
                do {
                    try context.save()
                }catch {
                    abort()
                }
                currentCell.deleteBtn.isSelected = false
            }
            
            let noAction = UIAlertAction(
                title: "Cancel", style: UIAlertAction.Style.default) {
                (action) -> Void in
//                currentCell.deleteBtn.isSelected = false
            }
            // 5.
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            // Check if Pro version
            if Context.getInstance().isProVersion() == false {
                (UIApplication.shared.delegate as! AppDelegate).showUpgradePopup(viewController: self)
                return
            }
            // send email
            let imgData  = self.fetchedResultsController.object(at: indexPath!).image
            let fileName = self.fetchedResultsController.object(at: indexPath!).certificateTitle
            let mailComposeViewController = configuredMailComposeViewController(imgData!,fileName!)
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func configuredMailComposeViewController(_ attachmentData:NSData , _ fileName : String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        let fileNamee = fileName+".png"
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("Attached Certificate from Diploma App")
        mailComposerVC.setMessageBody("My generated certificate from Diploma App is attached below of name"+" \(fileNamee)", isHTML: false)
        mailComposerVC.addAttachmentData(attachmentData as Data, mimeType: "image/png", fileName: fileNamee)
        return mailComposerVC
    } 

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let defaults = UserDefaults.standard
        defaults.set("Certificate", forKey: "Name")
        
        
//        let selectedCell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let tempVC = storyBoard.instantiateViewController(withIdentifier: "CertificateDetailsViewController") as! CertificateDetailsViewController
        tempVC.passingCertData(_cert: fetchedResultsController.object(at: indexPath))
//        tempVC.certImgView.image = selectedCell.imgView.image
        self.navigationController?.pushViewController(tempVC, animated: true)
    }

    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<DBCertificate> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<DBCertificate> = DBCertificate.fetchRequest()

        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "DBCertificate", in: managedObjContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "templateName", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<DBCertificate>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            showDeleteBtn = false
            navDeleteBtn.tintColor = UIColor.white
            self.configureCell(tableView.cellForRow(at: indexPath!) as! HomeTableViewCell, atIndexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}
