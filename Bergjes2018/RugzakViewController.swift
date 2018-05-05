//
//  RugzakViewController.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 29/04/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class RugzakViewController: UIViewController {
    @IBOutlet weak var rugzakContents: UITableView!
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in
            NSLog("done");
        });
    }
    
    override func viewDidLoad() {
        rugzakContents.delegate = self
        rugzakContents.dataSource = self
        
        rugzakContents.allowsMultipleSelection = true
        
    }
    
}

extension RugzakViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RugzakTableViewCell = self.rugzakContents.dequeueReusableCell(withIdentifier: "rugzakCell")! as! RugzakTableViewCell

        cell.rugzakCellLabel.text = "Item \(indexPath.row)"
        cell.rugzakCellImage.image = Utility.resizeImage(image: UIImage(named: "01. Zakmes")!,
                                                         targetSize: CGSize(width: 50.0, height: 50.0))

        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        // cell.accessoryView.hidden = !rowIsSelected // if using a custom image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        // cell.accessoryView.hidden = false // if using a custom image
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        // cell.accessoryView.hidden = true  // if using a custom image
    }
}

extension RugzakViewController: UITableViewDelegate {
    
    
}
