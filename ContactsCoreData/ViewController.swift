//
//  ViewController.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/13.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSFetchedResultsControllerDelegate {

    @IBOutlet var arrayController: NSArrayController!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var controller: NSFetchedResultsController<SW>!
    
    dynamic lazy var swManager: SWManager = {
        return SWManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? self.arrayController.fetch(with: nil, merge: false)
//        let fetchRequest: NSFetchRequest<SW> = SW.fetchRequest()
//        let dateSort = NSSortDescriptor(key: "chinesename", ascending: false)
//        fetchRequest.sortDescriptors = [dateSort]
//        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.swManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        controller.delegate = self
//        self.controller = controller
//        do {
//            try controller.performFetch()
//        } catch {
//            let error = error as NSError
//            print("\(error)")
//        }
    }
    
    override func viewDidAppear() {
        self.swManager.persistentContainer.viewContext.undoManager = self.undoManager
    }
    
    @IBAction func addClassesAction(_ sender: NSButton){
        let swes = NSEntityDescription.insertNewObject(forEntityName: "SW", into: self.swManager.persistentContainer.viewContext) as! SW
        swes.chinesename = "new";
    }
    
    @IBAction func deleteClassesAction(_ sender: NSButton){
        let selectedObjects:[SW]  = self.arrayController.selectedObjects as! [SW]
        for classObject: SW in selectedObjects {
            self.swManager.persistentContainer.viewContext.delete(classObject)
        }
    }
    
    @IBAction func uploadPhotoAction(_ sender: NSButton){
        let index = self.tableView.selectedRow
        if index < 0 {
            return
        }
        //self.openSelectClassPhotoFilePanel()
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
                    classObj.photo = imageData as NSData?
                }
            }
        })
    }
    
    @IBAction func saveAction(_ sender: NSButton){
        //let arrangedObjects = self.arrayController.arrangedObjects as! [SW]
       // let count = controller.sections?.count ?? 0
//        for index in 0..<count {
//            let classObj = arrangedObjects[index]
//            //print(classObj.description)
//        }//
        self.swManager.saveAction(sender)
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
        self.swManager.persistentContainer.viewContext.undoManager?.undo()
    }
    
    @IBAction func redo(_ sender: AnyObject){
        self.swManager.persistentContainer.viewContext.undoManager?.redo()
    }

}

