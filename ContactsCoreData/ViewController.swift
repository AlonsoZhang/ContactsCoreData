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
    
    let dlURL = "http://10.42.222.70/AEOverlay/Code_TOOLS/Contacts"
    
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
        let fileManager = FileManager.default
        let myDirectory:String = NSHomeDirectory() + "/Documents/Pic"
        let exist = fileManager.fileExists(atPath: myDirectory)
        if !exist {
            try! fileManager.createDirectory(atPath: myDirectory,withIntermediateDirectories: true, attributes: nil)
        }
        let url = URL(fileURLWithPath: myDirectory)
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
                urlSessionDownloadFileTest(member: memberinfoArr[2])
                
                let exist = fileManager.fileExists(atPath: myDirectory + "/" + memberinfoArr[2] + ".png")
                if exist {
                    let image = NSImage(contentsOf: url.appendingPathComponent("\(memberinfoArr[2]).png"))
                    if let imageRepresentations = image?.representations{
                        let imageData = NSBitmapImageRep.representationOfImageReps(in: imageRepresentations, using: .PNG, properties: [:])
                        swmember.photo = imageData as NSData?
                    }
                    else{
                        print("\(memberinfoArr[2]) error Pic")
                    }
                }else{
                    print("\(memberinfoArr[2]) no Pic")
                }
            }
            self.swManager.saveAction(nil)
        } else {
            print("Null")
        }
    }
    
    func sessionSimpleDownload(){
        let url = URL(string: "http://hangge.com/blog/images/logo.png")
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: request,
                                                completionHandler: {
                                                    (location:URL?, response:URLResponse?, error:Error?)
                                                    -> Void in
                                                    //输出下载文件原来的存放目录
                                                    print("location:\(String(describing: location))")
                                                    //location位置转换
                                                    let locationPath = location!.path
                                                    //拷贝到用户目录
                                                    let documnets:String = NSHomeDirectory() + "/Documents/1.png"
                                                    //创建文件管理器
                                                    let fileManager = FileManager.default
                                                    try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
                                                    print("new location:\(documnets)")
        })
        downloadTask.resume()
    }
    
    func urlSessionDownloadFileTest(member:String) {
        let defaultConfigObject = URLSessionConfiguration.default
        let session = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: nil)
        let urlmember = member.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "\(dlURL)/Pic/\(urlmember).png")!
        let task = session.downloadTask(with: url)
        task.resume()
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

extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileName = downloadTask.originalRequest?.url?.lastPathComponent
        let fileManager = FileManager.default
        let downloadURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Pic").appendingPathComponent(fileName!)
        do {
            try fileManager.moveItem(at: location, to: downloadURL)
        }
        catch let error {
            print("error \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("receive bytes \(bytesWritten) of totalBytes \(totalBytesExpectedToWrite)")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("resumeAtOffset  bytes \(fileOffset) of totalBytes \(expectedTotalBytes)")
    }
}
