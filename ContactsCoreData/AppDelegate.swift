//
//  AppDelegate.swift
//  ContactsCoreData
//
//  Created by Alonso on 2017/9/13.
//  Copyright © 2017年 Alonso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    

//    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
//        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//        return persistentContainer.viewContext.undoManager
//    }
//
//    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
//        // Save changes in the application's managed object context before the application terminates.
//        let context = persistentContainer.viewContext
//        
//        if !context.commitEditing() {
//            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
//            return .terminateCancel
//        }
//        
//        if !context.hasChanges {
//            return .terminateNow
//        }
//        
//        do {
//            try context.save()
//        } catch {
//            let nserror = error as NSError
//
//            // Customize this code block to include application-specific recovery steps.
//            let result = sender.presentError(nserror)
//            if (result) {
//                return .terminateCancel
//            }
//            
//            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
//            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
//            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
//            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
//            let alert = NSAlert()
//            alert.messageText = question
//            alert.informativeText = info
//            alert.addButton(withTitle: quitButton)
//            alert.addButton(withTitle: cancelButton)
//            
//            let answer = alert.runModal()
//            if answer == NSAlertSecondButtonReturn {
//                return .terminateCancel
//            }
//        }
//        // If we got here, it is time to quit.
//        return .terminateNow
//    }

}
