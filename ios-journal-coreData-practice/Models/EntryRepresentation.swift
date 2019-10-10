//
//  EntryRepresentation.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/8/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation
import CoreData

struct EntryRepresentation: Codable {
    var title: String
    var bodyText: String?
    var identifier: String
    var timestamp: Date
    var mood: String
}

