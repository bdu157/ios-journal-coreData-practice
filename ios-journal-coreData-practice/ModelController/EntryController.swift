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
    
    init() {
        self.fetchEntriesFromServer()
    }
    
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
    
    //GET
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = {_ in}) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data retruend by the data task")
                completion(NSError())
                return
            }
            
            do {
                let entryRepresentationsDictionary = try JSONDecoder().decode([String: EntryRepresentation].self, from: data)
                let entryRepresentations = entryRepresentationsDictionary.map{$0.value}
                try self.updateEntries(with: entryRepresentations)
                completion(nil)
            } catch {
                NSLog("Error decoding entry representation: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    
    //MARK: -------------------------CRUD------------------------------//
    //Create --------------------------------------------------------------------------
    func createEntry(title: String, bodyText: String, mood: Mood){
        let entry = Entry(title: title, bodyText: bodyText, mood: mood)
        
        self.put(entry: entry)
        
        self.saveToPersistentStore()
    }
    
    //Update -------------------------------------------------------------------------- updating core data and firebase
    func updateEntry(for entry: Entry, title: String, bodyText: String, timestamp: Date, mood: String) {
        entry.title = title
        entry.bodyText = bodyText
        entry.timestamp = timestamp
        entry.mood = mood
        
        self.put(entry: entry)
        
        self.saveToPersistentStore()
    }
    
    
    //MARK: - Syncing - Update fetchedDataFromTheServer and DatasinPersistentStore - Syncing datas between firebase(server) and persistentStore(coreData) - standard datas is based on firebase not coreData
    
    private func updateEntries(with representation: [EntryRepresentation]) throws {
        let entryWithID = representation.filter {$0.identifier != ""}
        let identifierToFetch = entryWithID.compactMap({$0.identifier}) //this could also be map
        
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifierToFetch, entryWithID))  //changed this way to compare easily
        
        var entryToCreate = representationByID
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifierToFetch)  //bring datas from persistentStore only if they have same identifiers from datas from the server (firebase)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            let existingEntries = try context.fetch(fetchRequest)  //datas from persistentStore
            
            for entry in existingEntries {
                guard let id = entry.identifier,
                    let representation = representationByID[id] else {continue}
                self.update(entry: entry, with: representation)  //update each object comparing representation (fetchedDatafromServer) and entry (datas in persistentStore)
                entryToCreate.removeValue(forKey: id) //remove the dictionary that i created above to use comparison in represenations and persistentstore data
            }
            
            //creatingEntries - entryToCreate(representationByID) was removed based on id (entry.identifier - persistentStore) so what this below does create new entries because they do not exsit in persistentStore after comparison between coreData (entry) and fetchedData (represenation)
            for representation in entryToCreate.values {
                Entry(entryRepresentation: representation, context: context) //this is creating based on representation (datas from the server but does not exist in coreData)
            }
        } catch {
            NSLog("Error fetching entries for UUID.uuidString: \(error)")
        }
        
        self.saveToPersistentStore()
    }
    
    //update datas from the server (firebase) and datas from persistentStore (coreData)
    func update(entry: Entry, with entryRepresentation: EntryRepresentation) {
        entry.title = entryRepresentation.title
        entry.bodyText = entryRepresentation.bodyText
        entry.timestamp = entryRepresentation.timestamp
        entry.mood = entryRepresentation.mood
    }
    
    //Delete --------------------------------------------------------------------------
    func deleteEntry(for entry: Entry) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(entry)
        
        self.deleteEntryFromServer(entry: entry)
        
        self.saveToPersistentStore()
    }
}
