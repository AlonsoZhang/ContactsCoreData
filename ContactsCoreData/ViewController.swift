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
        let swes = NSEntityDescription.insertNewObject(forEntityName: "SW", into: self.swManager.persistentContainer.viewContext) as! SW
        swes.chinesename = "new";
    }
    
    @IBAction func deleteAction(_ sender: NSButton){
        let selectedObjects:[SW]  = self.arrayController.selectedObjects as! [SW]
        for classObject: SW in selectedObjects {
            self.swManager.persistentContainer.viewContext.delete(classObject)
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
