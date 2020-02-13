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

    public func add(context: NSManagedObjectContext? = nil) -> T {
        return database.insert(moc: context)
    }

    public func delete(_ object: T, context: NSManagedObjectContext? = nil) {
        database.delete(object: object)
    }
    
    public func deleteAll(context: NSManagedObjectContext? = nil) {
        database.delete(entityName: String(describing: T.self), moc: context)
    }
    
    public func count(query: Query, context: NSManagedObjectContext? = nil) -> Int {
        return database.count(entityName: String(describing: T.self), predicate: query.predicate, moc: context)
    }
    
    public func find(by key: String = "id", value: Int, context: NSManagedObjectContext? = nil) -> [T] {
        let moc = context ?? database.mainContext
        let predicate = NSPredicate(format: "%K = %d", key, value)
        return database.fetch(entityName: String(describing: T.self), predicate: predicate, moc: moc)
    }
    
    public func find(by key: String = "id", value: String, context: NSManagedObjectContext? = nil) -> [T] {
        let moc = context ?? database.mainContext
        let predicate = NSPredicate(format: "%K = %@", key, value)
        return database.fetch(entityName: String(describing: T.self), predicate: predicate, moc: moc)
    }
    
    public func fetchAll(context: NSManagedObjectContext? = nil) -> [T] {
        let entities: [T] = self.database.fetch(entityName: String(describing: T.self), moc: context)
        return entities
    }
    
    public func fetchAll(sortDescriptor: NSSortDescriptor? = nil, context: NSManagedObjectContext? = nil) -> Single<[T]> {
        return Single.create(subscribe: { [unowned self] (single) -> Disposable in
            let entities: [T] = self.database.fetch(entityName: String(describing: T.self), sortDescriptor: sortDescriptor, moc: context)
            single(.success(entities))
            return Disposables.create()
        })
    }
    
    public func fetchAll(sortKey: String, context: NSManagedObjectContext? = nil) -> Single<[T]> {
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        return fetchAll(sortDescriptor: sortDescriptor, context: context)
    }

    public func fetch(_ query: Query, context: NSManagedObjectContext? = nil) -> Single<[T]> {
        let moc = context ?? database.mainContext

        let fetchRequest = NSFetchRequest<T>()
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: moc)

        fetchRequest.entity = entityDescription
        fetchRequest.predicate = query.predicate
        if let sortDescriptor = query.sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }

        return Single.create(subscribe: { (single) -> Disposable in
            self.database.backgroundFetch(fetchRequest, context: moc, completion: { (entities) in
                single(.success(entities))
            })

            return Disposables.create()
        })
    }
    
}
