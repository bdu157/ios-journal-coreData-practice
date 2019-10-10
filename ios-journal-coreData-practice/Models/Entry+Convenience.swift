//
//  Entry+Convenience.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/5/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation
import CoreData

enum Mood: String, CaseIterable {
    case sad = "😟"
    case fine = "🙂"
    case happy = "😋"
}


extension Entry {
    convenience init(title: String, bodyText: String, identifier: String = UUID().uuidString, timestamp: Date = Date(), mood: Mood = .fine , context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.identifier = identifier
        self.timestamp = timestamp
        self.mood = mood.rawValue
    }
    
    @discardableResult convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let bodyText = entryRepresentation.bodyText,
            let mood = Mood(rawValue: entryRepresentation.mood) else {return nil} //becaue this convenience has return value so you need to return nil here
        
        self.init(title: entryRepresentation.title,
                  bodyText: bodyText,
                  identifier: entryRepresentation.identifier,
                  timestamp: entryRepresentation.timestamp,
                  mood: mood,
                  context: context)
    }
    
    //computed property so we get the entryRepresentation
    var entryRepresentation: EntryRepresentation? {
        //make sure we have requried properties which are all besides bodyText
        guard let title = self.title,
            let identifier = self.identifier,
            let timestamp = self.timestamp,
            let mood = self.mood else {return nil}
        
        return EntryRepresentation(title: title, bodyText: bodyText, identifier: identifier, timestamp: timestamp, mood: mood)
    }
}
