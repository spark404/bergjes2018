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

protocol BlurredViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class RugzakViewController: UIViewController {
    var gameManager: GameManager?
    var items: [GameItem] = []
    var itemToUse: GameItem?
    
    @IBOutlet weak var rugzakContents: UITableView!
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var combineButton: UIBarButtonItem!
    @IBOutlet weak var useButton: UIBarButtonItem!
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in
            // Empty
        });
    }
    
    @IBAction func clickSelect(_ sender: Any) {
        // Basic toggle
        rugzakContents.allowsMultipleSelection = !rugzakContents.allowsMultipleSelection
        
        if (rugzakContents.allowsMultipleSelection) {
            selectButton.tintColor = UIColor.red
        } else {
            deselectAll();
            selectButton.tintColor = nil // Default
            combineButton.isEnabled = false
            useButton.isEnabled = false
        }
    }
    
    @IBAction func clickUse(_ sender: Any) {
        if let selectedRows = rugzakContents.indexPathsForSelectedRows {
            if (selectedRows.count == 1 ) {
                useItem(item: items[selectedRows[0].row])
            }
        }
    }
    
    @IBAction func clickCombine(_ sender: Any) {
        if let selectedRows = rugzakContents.indexPathsForSelectedRows {
            if (selectedRows.count == 2 ) {
                var itemsToCombine: [GameItem] = []
                itemsToCombine.append(items[selectedRows[0].row])
                itemsToCombine.append(items[selectedRows[1].row])
                if let result = gameManager?.attemptCombine(itemsToCombine: itemsToCombine) {
                    // It worked
                    showActionResult(message: result)
                } else {
                    showErrorResult(id1: itemsToCombine[0].name, id2: itemsToCombine[1].name)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        items = self.gameManager!.retrieveBackpackContents().filter({ $0.amount > 0 })
        
        rugzakContents.delegate = self
        rugzakContents.dataSource = self
        
        rugzakContents.allowsMultipleSelection = false
        rugzakContents.allowsSelection = true
        
        combineButton.isEnabled = false
        useButton.isEnabled = false
    }
    
    func updateAvailableActions() {
        if let selectedRows = rugzakContents.indexPathsForSelectedRows {
            combineButton.isEnabled = selectedRows.count > 1
            useButton.isEnabled = selectedRows.count == 1
        } else {
            useButton.isEnabled = false
            combineButton.isEnabled = false
        }
    }
    
    private func deselectAll() {
        if let visiblerows = rugzakContents.indexPathsForVisibleRows {
            for row in visiblerows {
                rugzakContents.cellForRow(at: row)!.accessoryType = .none
            }
        }
    }
    
    private func useItem(item: GameItem) {
        NSLog("Attempt to use \(item.name)")
        if let result = gameManager?.attemptUse(itemToUse: item) {
            // It worked
            showActionResult(message: result)
        } else {
            showErrorResult(id1: item.name, id2: gameManager!.currentLocationId)
        }
    }
    
    func displayItemInfoText(item: GameItem) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.overlayBlurredBackgroundView()
        
        let itemViewController = storyboard?.instantiateViewController(withIdentifier: "RugzakItemView") as! RugzakItemViewController
        itemViewController.gameManager = self.gameManager
        itemViewController.blurDelegate = self
        itemViewController.modalPresentationStyle = .overFullScreen
        
        itemViewController.item = item
        itemViewController.itemText = gameManager!.getDescriptionForItem(item: item)
        
        self.present(itemViewController, animated: true)
    }
        
    func showActionResult(message: String) {
        let refreshAlert = UIAlertController(title: "Tadaa!", message: message, preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            // OK
            self.items = self.gameManager!.retrieveBackpackContents().filter({ $0.amount > 0 })
            self.rugzakContents.reloadData()
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }

    func showErrorResult(id1: String, id2: String?) {
        let message = gameManager!.getErrorMessageForAttempt(identifier1: id1, identifier2: id2)
        let alert = UIAlertController(title: "Helaas", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            // OK
            self.items = self.gameManager!.retrieveBackpackContents().filter({ $0.amount > 0 })
            self.rugzakContents.reloadData()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension RugzakViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RugzakTableViewCell = self.rugzakContents.dequeueReusableCell(withIdentifier: "rugzakCell")! as! RugzakTableViewCell

        let item = items[indexPath.row]
        let itemImage = Utility.resizeImage(image: UIImage(named: item.imageReference)!,
                                            targetSize: CGSize(width: 50.0, height: 50.0))
        
        if item.amount > 1, item.name == "Munt" {
            cell.rugzakCellLabel.text = "\(item.amount) \(item.name)en"
        } else {
            cell.rugzakCellLabel.text = "\(item.name)"
        }
        
        cell.rugzakCellImage.image = itemImage
        cell.rugzakCellImage.highlightedImage = itemImage

        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        // cell.accessoryView.hidden = !rowIsSelected // if using a custom image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!rugzakContents.allowsMultipleSelection) {
            // Info mode, just diplay the item
            rugzakContents.deselectRow(at: indexPath, animated: false)
            self.displayItemInfoText(item: items[indexPath.row])
        } else {
            let cell = tableView.cellForRow(at: indexPath)!
            cell.accessoryType = .checkmark
            // cell.accessoryView.hidden = false // if using a custom image
            
            self.updateAvailableActions()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        // cell.accessoryView.hidden = true  // if using a custom image
        
        self.updateAvailableActions()
    }
}

extension RugzakViewController: UITableViewDelegate {
    
    
}

extension RugzakViewController: BlurredViewControllerDelegate {
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
    }
    
    func removeBlurredBackgroundView() {
        
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }
}
