//
//  EntryDetailViewController.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/3/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    var entry: Entry? {
        didSet {
            self.updateViews()
        }
    }
    var entryConteroller: EntryController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateViews()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = self.titleTextField.text,
            let bodyText = self.textView.text else {return}
        
        if let entry = entry {
            self.entryConteroller?.updateEntry(for: entry, title: title, bodyText: bodyText , timestamp: Date())
        } else {
            let _ = Entry(title: title, bodyText: bodyText)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        if isViewLoaded,
            let entry = entry {
            self.titleTextField.text = entry.title
            self.textView.text = entry.bodyText
            
        }
    }
}
