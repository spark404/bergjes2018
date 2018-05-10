//
//  RugzakItemViewController.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 06/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation
import UIKit

class RugzakItemViewController: UIViewController {
    var gameManager: GameManager?
    var item: GameItem?
    var location: GameLocation?
    var itemText: String?
    var useSelected: Bool = false
    
    var blurDelegate: BlurredViewControllerDelegate?
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var buttonUse: UIBarButtonItem!
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        closeRugzakItemView()
    }

    @IBAction func clickUse(_ sender: UIBarButtonItem) {
        useItem(item: item!)
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

    func showActionResult(message: String) {
        let refreshAlert = UIAlertController(title: "Tadaa!", message: message, preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.closeRugzakItemView()
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func showErrorResult(id1: String, id2: String?) {
        let message = gameManager!.getErrorMessageForAttempt(identifier1: id1, identifier2: id2)
        let alert = UIAlertController(title: "Helaas", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.closeRugzakItemView()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    func closeRugzakItemView() {
        blurDelegate?.removeBlurredBackgroundView()
        self.dismiss(animated: true, completion: {()->Void in
            NSLog("done");
        });
    }
    
    override func viewDidLoad() {
        if item != nil {
            itemImage.image = UIImage(named: item!.imageReference)
        } else if (location != nil) {
            if let reference = location!.imageReference {
                itemImage.image = UIImage(named: reference)
            }
            
            // Disable the use button
            buttonUse.isEnabled = false
            buttonUse.tintColor = UIColor.clear;
        }
        
        itemDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
        itemDescription.numberOfLines = 0
        itemDescription.text = itemText!;
    }
    
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor.clear
        
    }
}
