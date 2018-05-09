//
//  ManagementViewController.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class ManagementViewController: UIViewController {
    
    var gameManager: GameManager?
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in
            NSLog("close ManagementView");
        });
    }
    
    @IBAction func clickReset(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Reset?", message: "Reset all game data?", preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.gameManager?.resetGame()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // Empty
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func grantAllItems(_ sender: Any) {
        if let manager = gameManager {
            manager.inventory
                .filter { $0.amount == 0}
                .forEach{ $0.amount = 1 }
            manager.inventoryManager.updateInventory(gameItems: manager.inventory)
        }
    }
    
    
    override func viewDidLoad() {
        // Empty
    }
}
