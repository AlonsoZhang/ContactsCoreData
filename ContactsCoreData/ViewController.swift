//
//  ViewController.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/13.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    dynamic lazy var swManager: SWManager = {
        return SWManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? self.arrayController.fetch(with: nil, merge: false)
    }
    
    override func viewDidAppear() {
        self.swManager.persistentContainer.viewContext.undoManager = self.undoManager
    }
    
    @IBAction func addAction(_ sender: NSButton){
        let newmember = NSEntityDescription.insertNewObject(forEntityName: "SW", into: self.swManager.persistentContainer.viewContext) as! SW
        newmember.chinesename = "new";
        newmember.birthday = calcTimeInterval(dateStr: "2001-01-01")
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
    
    @IBAction func deleteAction(_ sender: NSButton){
        let selectedObjects:[SW]  = self.arrayController.selectedObjects as! [SW]
        for classObject: SW in selectedObjects {
            self.swManager.persistentContainer.viewContext.delete(classObject)
        }
    }
    
    @IBAction func inputAction(_ sender: NSButton) {
        let file = Bundle.main.path(forResource:"ContactsCSV", ofType: "csv")!
        let url = URL(fileURLWithPath: "/Users/alonso/Desktop/Pic")
        let manager = FileManager.default
        if let readData = NSData(contentsOfFile: file) {
            let readStr = NSString(data: readData as Data, encoding: String.Encoding.utf8.rawValue)!
            var readArr = readStr.components(separatedBy: "\r\n")
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
                let enumeratorAtPath = manager.enumerator(atPath: url.path)
                for logpath in enumeratorAtPath! {
                    if "\(logpath)" == "\(memberinfoArr[2]).png"{
                        let image = NSImage(contentsOf: url.appendingPathComponent("\(logpath)"))
                        let imageRepresentations = image?.representations
                        let imageData = NSBitmapImageRep.representationOfImageReps(in: imageRepresentations!, using: .PNG, properties: [:])
                        swmember.photo = imageData as NSData?
                    }
                }
            }
            self.swManager.saveAction(nil)
        } else {
            print("Null")
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
