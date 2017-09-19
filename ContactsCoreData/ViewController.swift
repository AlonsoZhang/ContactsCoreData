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
    
    let dlURL = "http://10.42.222.70/AEOverlay/Code_TOOLS/Contacts"
    
    dynamic lazy var swManager: SWManager = {
        return SWManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? self.arrayController.fetch(with: nil, merge: true)
//        let contact = Contacts()
//        
//        let saveContactRequest = CNSaveRequest()
//        do{
//            let groups = try CNContactStore().groups(matching: nil)
//            //print(groups)
//        }catch{
//            //print(error)
//        }
        //let addGroupRequest = CNSaveRequest.init()
        
        //let c = CNMutableContact()
        //contact.setNewContact(contact: c, name: "张三", engname: "san zhang", phoneNum: "15700000000", shortNum: "666666")
        //saveContactRequest.addMember(c, to: <#T##CNGroup#>)
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
    
    func calcTimeInterval(dateStr:String) -> TimeInterval {
        let format = "yyyy-MM-dd"
        var newdateStr = dateStr
        if dateStr.characters.count != format.characters.count {
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
    
    func setPhotoData(picname:String) -> NSData {
        let image = NSImage(named: picname)
        let imageRep = NSBitmapImageRep(data: (image?.tiffRepresentation)!)
        let imageData = imageRep?.representation(using: .PNG, properties: [:])
        return imageData! as NSData
    }
    
    @IBAction func deleteAction(_ sender: NSButton){
        let selectedObjects:[SW]  = self.arrayController.selectedObjects as! [SW]
        for classObject: SW in selectedObjects {
            self.swManager.persistentContainer.viewContext.delete(classObject)
        }
    }
    
    @IBAction func inputAction(_ sender: NSButton) {
        let selectedObjects:[SW]  = self.arrayController.arrangedObjects as! [SW]
        for classObject: SW in selectedObjects {
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
    
    func loadcsvdata(str:String) {
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
            let url = URL(string: "\(dlURL)/Pic/\(urlmember).png")!
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
                DispatchQueue.main.async {
                    self.swManager.saveAction(nil)
                }
            }) as URLSessionTask
            dataTask.resume()
        }
    }
    
    @IBAction func saveAction(_ sender: NSButton){
        self.swManager.saveAction(sender)
    }
    
    @IBAction func queryAction(_ sender: NSSearchField) {
        let content = sender.stringValue
        if content.characters.count <= 0 {
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
}
