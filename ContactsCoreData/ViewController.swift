//
//  ViewController.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/13.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Cocoa
import Contacts

class ViewController: NSViewController {
    
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var clearBtn: NSButton!
    @objc let GROUP_NAME = "WKS-SW"
    
    @objc var contacts:NSMutableArray = []
    
    //@objc let dlURL = "http://10.42.222.70/AEOverlay/Code_TOOLS/Contacts"
    
    @objc let dlURL = "http://7xrqwh.com1.z0.glb.clouddn.com"
    
    @objc dynamic lazy var swManager: SWManager = {
        return SWManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? self.arrayController.fetch(with: nil, merge: true)
    }
    
    override func viewDidAppear() {
        self.swManager.persistentContainer.viewContext.undoManager = self.undoManager
    }
    
    @IBAction func addAction(_ sender: NSButton){
        let newmember = NSEntityDescription.insertNewObject(forEntityName: "SW", into: self.swManager.persistentContainer.viewContext) as! SW
        newmember.chinesename = "new";
        newmember.birthday = calcTimeInterval(dateStr: "2001-01-01")
        newmember.photo = setPhotoData(picname: "Person")
    }
    
    @objc func calcTimeInterval(dateStr:String) -> TimeInterval {
        let format = "yyyy-MM-dd"
        var newdateStr = dateStr
        if dateStr.count != format.count {
            newdateStr = "2001-01-01"
        }
        let dformatter = DateFormatter()
        dformatter.dateFormat = format
        dformatter.timeZone = TimeZone(abbreviation: "GMT")
        let sinceDate = dformatter.date(from: "2001-01-01")
        let birthdayDate = dformatter.date(from: newdateStr)
        let timeInterval:TimeInterval = birthdayDate!.timeIntervalSince(sinceDate!)
        return timeInterval
    }
    
    @objc func setPhotoData(picname:String) -> NSData {
        let image = NSImage(named: NSImage.Name(rawValue: picname))
        let imageRep = NSBitmapImageRep(data: (image?.tiffRepresentation)!)
        let imageData = imageRep?.representation(using: .png, properties: [:])
        return imageData! as NSData
    }
    
    @IBAction func deleteAction(_ sender: NSButton){
        let selectedObjects:[SW]  = self.arrayController.selectedObjects as! [SW]
        for classObject: SW in selectedObjects {
            self.swManager.persistentContainer.viewContext.delete(classObject)
        }
    }
    
    @IBAction func inputAction(_ sender: NSButton) {
        let arrangedObjects:[SW]  = self.arrayController.arrangedObjects as! [SW]
        for classObject: SW in arrangedObjects {
            self.swManager.persistentContainer.viewContext.delete(classObject)
        }
        let csvurl = URL(string: "\(dlURL)/ContactsCSV.csv")!
        let csvrequest = URLRequest(url: csvurl)
        let csvsession = URLSession.shared
        let csvdataTask = csvsession.dataTask(with: csvrequest, completionHandler: {(data, response, error) -> Void in
            if error == nil{
                if let csvstr =  NSString(data:data! ,encoding: String.Encoding.utf8.rawValue){
                    self.loadcsvdata(str:csvstr as String)
                }
            }else{
                print("error")
            }
        }) as URLSessionTask
        csvdataTask.resume()
    }
    
    @objc func loadcsvdata(str:String) {
        var readArr = str.components(separatedBy: "\r\n")
        readArr.remove(at: 0)
        for eachmember in readArr {
            let swmember = NSEntityDescription.insertNewObject(forEntityName: "SW", into: self.swManager.persistentContainer.viewContext) as! SW
            let memberinfoArr = eachmember.components(separatedBy: ",")
            swmember.department = memberinfoArr[0]
            swmember.chinesename = memberinfoArr[1]
            swmember.englishname = memberinfoArr[2]
            swmember.employeeid = memberinfoArr[3]
            swmember.birthday = calcTimeInterval(dateStr: memberinfoArr[4])
            swmember.photonumber = memberinfoArr[6]
            swmember.shortnumber = memberinfoArr[7]
            swmember.email = memberinfoArr[9]
            swmember.imessage = memberinfoArr[10]
            let urlmember = memberinfoArr[2].replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: "\(dlURL)/contactpic/\(urlmember).png")!
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request,completionHandler: {(data, response, error) -> Void in
                if error == nil{
                    if let imagedata = data {
                        let httpResponse = response as! HTTPURLResponse
                        if (httpResponse.statusCode == 404){
                            swmember.photo = self.setPhotoData(picname: "Person")
                        }else{
                            swmember.photo = imagedata as NSObject
                        }
                    }
                }else{
                    swmember.photo = self.setPhotoData(picname: "Person")
                }
//                DispatchQueue.main.async {
//                    self.swManager.saveAction(nil)
//                }
            }) as URLSessionTask
            dataTask.resume()
        }
    }
    
    @IBAction func saveAction(_ sender: NSButton){
        self.swManager.saveAction(sender)
    }
    
    @IBAction func queryAction(_ sender: NSSearchField) {
        let content = sender.stringValue
        if content.count <= 0 {
            return
        }
        let predicate: NSPredicate = NSPredicate(format:content)
        self.arrayController.filterPredicate = predicate
    }
    
    @IBAction func undoAction(_ sender: NSButton) {
        self.swManager.persistentContainer.viewContext.undoManager?.undo()
    }
    
    @IBAction func redoAction(_ sender: NSButton) {
        self.swManager.persistentContainer.viewContext.undoManager?.redo()
    }
    
    @IBAction func inputContacts(_ sender: NSButton) {
        self.swManager.saveAction(nil)
        clearInput(clearBtn)
        let contact = Contacts()
        let saveContactRequest = CNSaveRequest()
        let saveGroupRequest = CNSaveRequest()
        let store = CNContactStore()
        let newgroup = CNMutableGroup()
        newgroup.name = GROUP_NAME
        saveGroupRequest.add(newgroup, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveGroupRequest)
            print("Add new group:"+"\(newgroup)")
        }catch{
            print(error)
        }
        
        let arrangedObjects:[SW]  = self.arrayController.arrangedObjects as! [SW]
        for classObject: SW in arrangedObjects {
            let c = CNMutableContact()
            let birthdaycomponents = calcDateComponents(timeinterval: classObject.birthday)
            contact.setNewContact(c, name: classObject.chinesename, engname: classObject.englishname, phoneNum: classObject.photonumber, shortNum: classObject.shortnumber, note: classObject.employeeid, birthday: birthdaycomponents, email: classObject.email, imessage: classObject.imessage, photo: classObject.photo as! Data, department: GROUP_NAME)
            saveContactRequest.add(c, toContainerWithIdentifier: nil)
            saveContactRequest.addMember(c, to: newgroup)
        }
        do {
            try store.execute(saveContactRequest)
        }catch{
            print(error)
        }
    }
    
    @objc func calcDateComponents(timeinterval:TimeInterval) -> DateComponents {
        let format = "yyyy-MM-dd"
        let dformatter = DateFormatter()
        dformatter.dateFormat = format
        dformatter.timeZone = TimeZone(abbreviation: "GMT")
        let sinceDate = dformatter.date(from: "2001-01-01")
        let calendar = Calendar.current
        let calculatedDate = sinceDate?.addingTimeInterval(timeinterval)
        let components = calendar.dateComponents([.year, .month, .day], from: calculatedDate!)
        return components
    }
    
    @IBAction func clearInput(_ sender: NSButton) {
        let contactclass = Contacts()
        contacts = contactclass.fetchcontact()
        for existconst in contacts {
            let existcontact = (existconst as! CNContact).mutableCopy() as! CNMutableContact
            if existcontact.departmentName == GROUP_NAME{
                contactclass.delete(existcontact)
            }
        }
        let store = CNContactStore()
        let deleteGroupRequest = CNSaveRequest()
        do{
            let groups = try store.groups(matching: nil)
            for existgroup in groups {
                if existgroup.name == GROUP_NAME {
                    let existmutablegroup = existgroup.mutableCopy() as! CNMutableGroup
                    deleteGroupRequest.delete(existmutablegroup)
                }
            }
        }catch{
            print(error)
        }
        do{
            try store.execute(deleteGroupRequest)
        }catch{
            print(error)
        }
    }
}
