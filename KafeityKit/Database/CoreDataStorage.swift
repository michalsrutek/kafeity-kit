//
//  CoreDataStorage.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import CoreData


public class CoreDataStorage {
    
    // MARK: - Initialization
    
    private let modelName: String
    private let fileName: String?
    private let bundle: Bundle?
    
    public init(modelName: String, fileName: String?, bundle: Bundle?) {
        self.modelName = modelName
        self.fileName = fileName
        self.bundle = bundle
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSavePrivateQueueContext(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.privateQueueCtxt)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveMainQueueContext(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.mainQueueCtxt)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notifications
    
    @objc func contextDidSavePrivateQueueContext(notification: Notification) {
        if let context = self.mainQueueCtxt {
            print("Merge - Private Context")
            self.synced(lock: self, closure: { () -> () in
                context.perform({() -> Void in
                    context.mergeChanges(fromContextDidSave: notification)
                })
            })
        }
    }
    
    @objc func contextDidSaveMainQueueContext(notification: Notification) {
        if let context = self.privateQueueCtxt {
            print("Merge - Main Context")
            self.synced(lock: self, closure: { () -> () in
                context.perform({() -> Void in
                    context.mergeChanges(fromContextDidSave: notification)
                })
            })
        }
    }

    private func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = (bundle ?? Bundle(for: CoreDataStorage.self)).url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var storeOptions = {
        return [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("\(fileName ?? "Model").sqlite")

        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: storeOptions)
        } catch var error as NSError {
            coordinator = nil
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        print(String(describing: coordinator?.persistentStores))
        return coordinator
    }()
    
    // MARK: - NSManagedObject Contexts

    lazy var mainQueueCtxt: NSManagedObjectContext? = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy var privateQueueCtxt: NSManagedObjectContext? = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    
    func saveContext(context: NSManagedObjectContext?) {
        if let moc = context {
            if moc.hasChanges {
                do {
                    try moc.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }
}
