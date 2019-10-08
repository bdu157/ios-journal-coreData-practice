//
//  EntryController.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/5/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation
import CoreData

var baseURL = URL(string: "https://task-coredata.firebaseio.com/")!

class EntryController {
    
    typealias CompletionHandler = (Error?) -> Void

    /* - We no longer need
    var entries: [Entry] {
        return self.loadFromPersistentStore()
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
    */
    //SaveToCoreDataStore
    func saveToPersistentStore() {
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context:\(error)")
        }
    }
    
    //MARK: -------------------------Networking------------------------------//
    
    //PUT
    func put(entry: Entry, completion:@escaping () -> Void = {}) { // giving an empty closure here so it wont need to have this closure being handled when it gets called
        let uuidString = entry.identifier ?? UUID().uuidString
        let requestURL = baseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = entry.entryRepresentation else {
                completion()
                return
            }
            
            representation.identifier = uuidString
            entry.identifier = uuidString
            self.saveToPersistentStore()
            
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding entry \(entry):\(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing entry to servre: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    //DELETE
    func deleteEntryFromServer(entry: Entry, completion: @escaping CompletionHandler = {_ in}) {
        guard let uuidString = entry.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
        }.resume()
    }
    
    
    //MARK: -------------------------CRUD------------------------------//
    //Create --------------------------------------------------------------------------
    func createEntry(title: String, bodyText: String, mood: Mood){
        let entry = Entry(title: title, bodyText: bodyText, mood: mood)
        
        self.put(entry: entry)
        
        self.saveToPersistentStore()
    }
    
    //Update --------------------------------------------------------------------------
    func updateEntry(for entry: Entry, title: String, bodyText: String, timestamp: Date, mood: String) {
        entry.title = title
        entry.bodyText = bodyText
        entry.timestamp = timestamp
        entry.mood = mood
        
        self.put(entry: entry)
        
        self.saveToPersistentStore()
    }
    
    //Delete --------------------------------------------------------------------------
    func deleteEntry(for entry: Entry) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(entry)
        
        self.deleteEntryFromServer(entry: entry)
        
        self.saveToPersistentStore()
    }
}
