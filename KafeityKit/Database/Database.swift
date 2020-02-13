//
//  Database.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import CoreData

public class Database {
    
    public var mainContext: NSManagedObjectContext {
        return coreDataStorage.mainQueueCtxt!
    }
    
    public var privateContext: NSManagedObjectContext {
        return coreDataStorage.privateQueueCtxt!
    }

    private let coreDataStorage: CoreDataStorage
    
    public init(storage: CoreDataStorage) {
        coreDataStorage = storage
    }

    public func save(moc: NSManagedObjectContext? = nil) {
        let moc = moc ?? mainContext
        coreDataStorage.saveContext(context: moc)
    }

    func insert<T>(moc: NSManagedObjectContext? = nil) -> T where T: Entity, T: NSManagedObject {
        let moc = moc ?? mainContext
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: moc) as! T
    }

    func delete(object: NSManagedObject) {
        guard let moc = object.managedObjectContext else {
            return
        }
        moc.delete(object)
        save(moc: moc)
    }
    
    func count(entityName: String, predicate: NSPredicate, moc: NSManagedObjectContext? = nil) -> Int {
        let moc = moc ?? mainContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        return (try? moc.count(for: fetchRequest)) ?? 0
    }

    func delete(entityName: String, predicate: NSPredicate? = nil, moc: NSManagedObjectContext? = nil) {
        let moc = moc ?? mainContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            let result = try moc.persistentStoreCoordinator?.execute(deleteRequest, with: moc)
            if let ids = (result as? NSBatchDeleteResult)?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
            }
        }
        catch {
            print(error)
        }
    }

    func fetch<EntityType: NSFetchRequestResult>(entityName: String, sortDescriptor: NSSortDescriptor? = nil, fetchLimit: Int? = nil, moc: NSManagedObjectContext? = nil) -> [EntityType] {
        let moc = moc ?? mainContext
        
        let fetchRequest = NSFetchRequest<EntityType>(entityName: entityName)
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        if let objects = (try? moc.fetch(fetchRequest)) {
            return objects
        }
        return []
    }
    
    func fetch<EntityType: NSManagedObject>(modelsIds: [NSManagedObjectID], moc: NSManagedObjectContext? = nil) -> [EntityType] {
        let moc = moc ?? mainContext
        
        var models = [EntityType]()
        for modelId in modelsIds {
            guard let model = moc.object(with: modelId) as? EntityType else {
                continue
            }
            models.append(model)
        }
        return models
    }
    
    func fetch<EntityType: NSManagedObject>(entityName: String, predicate: NSPredicate, sortDescriptor: NSSortDescriptor? = nil, fetchLimit: Int? = nil, moc: NSManagedObjectContext? = nil) -> [EntityType] {
        let moc = moc ?? mainContext
        
        let fetchRequest = NSFetchRequest<EntityType>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        if let objects = (try? moc.fetch(fetchRequest)) {
            return objects
        }
        return []
    }
    
    func backgroundFetch<T>(_ fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext? = nil, completion: @escaping ([T]) -> Void) where T: NSManagedObject {
        // Background fetch and pass to main
        let moc = context ?? mainContext
        let backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        backgroundManagedObjectContext.persistentStoreCoordinator = moc.persistentStoreCoordinator
        
        backgroundManagedObjectContext.perform { () -> Void in
            var fetchedObjectsIds = [NSManagedObjectID]()
            do {
                let fetchedObjects = try backgroundManagedObjectContext.fetch(fetchRequest)
                for fetchedObject in fetchedObjects {
                    fetchedObjectsIds.append(fetchedObject.objectID)
                }
            }
            catch {
                print("Database: Background Fetch Failed")
                print(error)
            }
            
            moc.perform {
                var objects = [T]()
                for fetchedObjectId in fetchedObjectsIds {
                    if let object = moc.object(with: fetchedObjectId) as? T {
                        objects.append(object)
                    }
                }
                completion(objects)
            }
        }
    }

    func clear(entities: [Entity.Type], moc: NSManagedObjectContext? = nil) {
        for entity in entities {
            delete(entityName: entity.entityName, moc: moc)
        }
    }
}
