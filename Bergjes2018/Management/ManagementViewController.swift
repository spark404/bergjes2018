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
    @IBOutlet weak var buttonSellTouw: UIButton!
    @IBOutlet weak var buttonSellLemmet: UIButton!
    @IBOutlet weak var buttonSellDuikbril: UIButton!
    @IBOutlet weak var buttonSellSmeerolie: UIButton!
    @IBOutlet weak var buttonAllVisible: UIButton!
    
    @IBOutlet weak var labelLattitude: UILabel!
    @IBOutlet weak var labelLongitude: UILabel!
    
    var gameManager: GameManager?
    var locationUpdateTimer: Timer!
    
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
    
    @IBAction func sellTouw(_ sender: Any) {
        sellItem(itemId: "Touw")
    }
    
    @IBAction func sellLemmet(_ sender: Any) {
        sellItem(itemId: "Lemmet")
    }
    
    @IBAction func sellDuikbril(_ sender: Any) {
        sellItem(itemId: "Duikbril")
    }
    
    @IBAction func sellSmeerolie(_ sender: Any) {
        sellItem(itemId: "Smeerolie")
    }

    
    @IBAction func grantAllItems(_ sender: Any) {
        if let manager = gameManager {
            manager.inventory
                .filter { $0.amount == 0}
                .forEach{ $0.amount = 1 }
            manager.inventoryManager.updateInventory(gameItems: manager.inventory)
        }
    }
    @IBAction func buttonAllVisible(_ sender: Any) {
        gameManager!.forceAllVisible = !gameManager!.forceAllVisible
        buttonAllVisible.tintColor = gameManager!.forceAllVisible ? .red : nil
        
        let managementLocation = GameLocation(name: "management", latitude: 0, longitude: 0)
        gameManager!.updateCurrentLocation(playerPosition: managementLocation, force: true)
    }
    
    
    override func viewDidLoad() {
        updateAvailableItems()
        
        buttonAllVisible.tintColor = gameManager!.forceAllVisible ? .red : nil
        
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                             selector: #selector(updateLocation), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationUpdateTimer.invalidate()
        locationUpdateTimer = nil
    }
    
    @objc func updateLocation() {
        if let parentVc = self.presentingViewController as? ViewController,
            let currentPosition = parentVc.position {
                labelLattitude.text = "Latitude: \(currentPosition.coordinate.latitude)"
                labelLongitude.text = "Longitude: \(currentPosition.coordinate.longitude)"
            }
    }

    func updateAvailableItems() {
        if let munt = gameManager?.inventory.first(where: {$0.name == "Munt"})
        {
            if let price = gameManager?.merchantPrices["Touw"] {
                buttonSellTouw.isEnabled = munt.amount >= price
            }
            if let price = gameManager?.merchantPrices["Lemmet"] {
                buttonSellLemmet.isEnabled = munt.amount >= price
            }
            if let price = gameManager?.merchantPrices["Duikbril"] {
                buttonSellDuikbril.isEnabled = munt.amount >= price
            }
            if let price = gameManager?.merchantPrices["Smeerolie"] {
                buttonSellSmeerolie.isEnabled = munt.amount >= price
            }
        } else {
            buttonSellTouw.isEnabled = false
            buttonSellSmeerolie.isEnabled = false
            buttonSellDuikbril.isEnabled = false
            buttonSellLemmet.isEnabled = false
        }
    }
    
    func sellItem(itemId: String) {
        if let munt = gameManager?.inventory.first(where: {$0.name == "Munt"}),
            let price = gameManager?.merchantPrices[itemId]
        {
            if (munt.amount >= price) {
                gameManager?.addItemToInventory(itemName: itemId)
                _ = gameManager?.removeItemFromInventory(itemName: "Munt", amount: price)
            } else {
                showAlert(message: "\(price) Munten nodig voor een \(itemId), \(munt.amount) beschikbaar")
            }
        }
        updateAvailableItems()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Let op!", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            // Empty
        }))
        
        present(alert, animated: true, completion: nil)

    }
}
