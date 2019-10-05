//
//  EntryTableViewCell.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/3/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var entry: Entry? {
        didSet {
            self.updateViews()
        }
    }
    
    private func updateViews() {
        guard let entry = entry else {return}
        self.titleLabel.text = entry.title
        self.bodyTextLabel.text = entry.bodyText
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        self.timeLabel.text = df.string(from: entry.timestamp!)
    }

}
