//
//  EntryController.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/5/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation
import CoreData

class EntryController {
    
    
    var entries: [Entry] {
        return self.loadFromPersistentStore()
    }

    
    func saveToPersistentStore() {
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context:\(error)")
        }
    }
    
    func loadFromPersistentStore() -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        
        do {
            return try moc.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
    
    
    
    //Create
    func createEntry(title: String, bodyText: String, mood: Mood){
        let _ = Entry(title: title, bodyText: bodyText, mood: mood)
        
        self.saveToPersistentStore()
    }
    
    //Update
    func updateEntry(for entry: Entry, title: String, bodyText: String, timestamp: Date, mood: String) {
        entry.title = title
        entry.bodyText = bodyText
        entry.timestamp = timestamp
        entry.mood = mood
        
        self.saveToPersistentStore()
    }
    
    //Delete
    func deleteEntry(for entry: Entry) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(entry)
        
        self.saveToPersistentStore()
    }
}
