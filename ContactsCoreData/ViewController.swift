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
    dynamic lazy var classesManager: ClassesManager = {
        return ClassesManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? self.arrayController.fetch(with: nil, merge: false)
        let directory = NSHomeDirectory()
        print(directory)
    }
    
    override func viewDidAppear() {
        self.classesManager.persistentContainer.viewContext.undoManager = self.undoManager
    }
    
    @IBAction func addClassesAction(_ sender: NSButton){
        let classes = NSEntityDescription.insertNewObject(forEntityName: "SW", into: self.classesManager.persistentContainer.viewContext) as! SW
//        classes.chinesename = "unTitled";
//        classes.studentsNum = 0;
//        classes.motto = "qqq";
        
    }
    
    @IBAction func deleteClassesAction(_ sender: NSButton){
        let selectedObjects:[SW]  = self.arrayController.selectedObjects as! [SW]
        for classObject: SW  in selectedObjects {
            self.classesManager.persistentContainer.viewContext.delete(classObject)
        }
    }
    
    
    @IBAction func uploadPhotoAction(_ sender: NSButton){
        let index = self.tableView.selectedRow
        if index < 0 {
            return
        }
        self.openSelectClassPhotoFilePanel()
    }
    
    func openSelectClassPhotoFilePanel() {
        let openDlg = NSOpenPanel()
        openDlg.canChooseFiles = true
        openDlg.canChooseDirectories = false
        openDlg.allowsMultipleSelection = false
        openDlg.allowedFileTypes = ["png"]
        
        openDlg.begin(completionHandler: { [weak self]  result in
            if(result == NSFileHandlingPanelOKButton){
                let fileURLs = openDlg.urls
                for url:URL in fileURLs  {
                    let image = NSImage(contentsOf: url as URL)
                    let imageRepresentations = image?.representations
                    let imageData = NSBitmapImageRep.representationOfImageReps(in: imageRepresentations!, using: .PNG, properties: [:])
                    let arrangedObjects = self?.arrayController.arrangedObjects as! [SW]
                    let index = self?.tableView.selectedRow
                    let classObj = arrangedObjects[index!]
                    classObj.photo = imageData as NSData?;
                }
            }
        })
    }
    
    @IBAction func saveAction(_ sender: NSButton){
        self.classesManager.saveAction(sender)
    }
    
    
    @IBAction func queryClassesAction(_ sender: NSSearchField) {
        
        let content = sender.stringValue
        if content.characters.count <= 0 {
            return
        }
        
        let predicate: NSPredicate = NSPredicate(format:content)
        self.arrayController.filterPredicate = predicate
        
    }
    
    @IBAction func undo(_ sender: AnyObject){
        self.classesManager.persistentContainer.viewContext.undoManager?.undo()
    }
    
    @IBAction func redo(_ sender: AnyObject){
        self.classesManager.persistentContainer.viewContext.undoManager?.redo()
    }

}

