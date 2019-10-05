//
//  EntriesTableViewController.swift
//  ios-journal-coreData-practice
//
//  Created by Dongwoo Pae on 10/3/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import UIKit

class EntriesTableViewController: UITableViewController {
    
    let entryController = EntryController()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.entryController.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath)

        let entry = self.entryController.entries[indexPath.row]
        guard let customCell = cell as? EntryTableViewCell else {return UITableViewCell()}
        customCell.entry = entry
        return cell
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = self.entryController.entries[indexPath.row]
            self.entryController.deleteEntry(for: entry)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateJournal" {
            guard let destVC = segue.destination as? EntryDetailViewController else {return}
                destVC.entryConteroller = self.entryController
        } else if segue.identifier == "toShowJournal" {
            guard let destVC = segue.destination as? EntryDetailViewController,
                let selectedRow = tableView.indexPathForSelectedRow else {return}
                destVC.entryConteroller = self.entryController
                destVC.entry = self.entryController.entries[selectedRow.row]
        }
    }


}
