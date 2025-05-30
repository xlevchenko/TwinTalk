//
//  PersistenceManager.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import Foundation


import Foundation
import CoreData

class PersistenceManager {
    static let instance = PersistenceManager()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "Models")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data initialization error: \(error)")
            }
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
                context.rollback()
            }
        }
    }
    
    func syncSessions(_ sessions: [Session]) {
        for session in sessions {
            let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", session.id)
            
            let existingSession = (try? context.fetch(fetchRequest))?.first
            
            let sessionEntity = existingSession ?? SessionEntity(context: context)
            
            sessionEntity.id = session.id
            sessionEntity.date = session.date 
            sessionEntity.title = session.title
            sessionEntity.category = session.category
            sessionEntity.summary = session.summary
            
            if let existingMessages = sessionEntity.messages as? Set<MessageEntity> {
                for message in existingMessages {
                    context.delete(message)
                }
            }
            
            for message in session.messages {
                let messageEntity = MessageEntity(context: context)
                messageEntity.id = message.id
                messageEntity.text = message.text
                messageEntity.sender = message.sender.rawValue
                messageEntity.timestamp = ISO8601DateFormatter.shared.date(from: message.timestamp)
                messageEntity.session = sessionEntity
            }
        }
        saveContext()
    }
    
    func loadStoredSessions() -> [Session] {
        let request: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                Session(
                    id: entity.id ?? "",
                    date: entity.date ?? "",
                    title: entity.title ?? "",
                    category: entity.category ?? "",
                    summary: entity.summary ?? "",
                    messages: (entity.messages as? Set<MessageEntity>)?
                        .sorted(by: { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) })
                        .map { message in
                            Message(
                                id: message.id ?? "", text: message.text ?? "",
                                sender: Sender(rawValue: message.sender ?? "") ?? .user,
                                timestamp: ISO8601DateFormatter().string(from: message.timestamp ?? Date())
                            )
                        } ?? []
                )
            }
        } catch {
            print("❌ Failed to fetch sessions from Core Data: \(error)")
            return []
        }
    }
}
