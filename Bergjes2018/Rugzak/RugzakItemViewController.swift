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
    var delegate: RugzakItemViewControllerDelegate?
    var item: GameItem?
    var location: GameLocation?
    var itemText: String?
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        delegate?.removeBlurredBackgroundView()
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
        }
        
        itemDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
        itemDescription.numberOfLines = 0
        itemDescription.text = itemText!;
    }
    
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor.clear
        
    }
}

protocol RugzakItemViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

