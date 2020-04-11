//
//  NewTripViewController.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController {
    @IBOutlet weak var clientIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clientIdTextField.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clientIdTextField.becomeFirstResponder()
    }
    
    @IBAction func onStartPressed(_ sender: Any) {
        startNewTrip()
    }
    
    func startNewTrip() {
        print("Starting trip...")
        if let presenter = presentingViewController as? MapViewController {
            let newTrip = TripData(startDate: Date(), clientId: clientIdTextField.text)
            dismiss(animated: true, completion: {
                presenter.startNewTrip(trip: newTrip)
            })
        }
    }
}

//MARK: - Text Field Delegate
extension NewTripViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == clientIdTextField {
            startNewTrip()
            return false
        }
        return true
    }
}
