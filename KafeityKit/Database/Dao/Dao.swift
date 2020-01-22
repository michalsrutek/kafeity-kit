//
//  Dao.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import CoreData
import RxSwift
import RxCocoa


open class Dao<T> where T: NSManagedObject, T: Entity {

    public let database: Database

    public init(database: Database) {
        self.database = database
    }

    public func save(context: NSManagedObjectContext? = nil) {
        database.save(moc: context)
    }

    public func add(context: NSManagedObjectContext? = nil) -> T {
        return database.insert(moc: context)
    }

    public func delete(_ object: T, context: NSManagedObjectContext? = nil) {
        database.delete(object: object)
    }

    public func deleteAll(context: NSManagedObjectContext? = nil) {
        database.delete(entityName: T.entityName, moc: context)
    }

    public func fetch(_ query: Query, context: NSManagedObjectContext? = nil) -> T? {
        let moc = context ?? database.mainContext

        return database.fetch(entityName: T.entityName, predicate: query.predicate, moc: moc).first
    }

    public func fetch(_ query: Query, context: NSManagedObjectContext? = nil) -> Single<[T]> {
        let moc = context ?? database.mainContext
        let fetchRequest = NSFetchRequest<T>()
        let entityDescription = NSEntityDescription.entity(forEntityName: T.entityName, in: moc)

        fetchRequest.entity = entityDescription
        fetchRequest.predicate = query.predicate
        if let sortDescriptor = query.sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        if let fetchOffset = query.fetchOffset {
            fetchRequest.fetchOffset = fetchOffset
        }
        if let fetchLimit = query.fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }

        return Single.create(subscribe: { (single) -> Disposable in
            self.database.backgroundFetch(fetchRequest, context: moc, completion: { (entities) in
                single(.success(entities))
            })

            return Disposables.create()
        })
    }
    
}
