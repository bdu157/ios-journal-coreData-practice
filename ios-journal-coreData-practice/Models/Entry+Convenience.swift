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
}
