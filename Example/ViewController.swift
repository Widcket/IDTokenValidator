//
//  ViewController.swift
//  IDTokenValidatorExample
//
//  Created by Rita Zerrizuela on 10/09/2019.
//  Copyright © 2019 Rita Zerrizuela. All rights reserved.
//

import UIKit
import Auth0
import IDTokenValidator

class ViewController: UIViewController {
    @IBAction func didTapLoginButton() {
        Auth0
            .webAuth()
            .audience("https://widcket.auth0.com/userinfo")
            .start { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    
                    if IDTokenValidator.validate(credentials.idToken) {
                        print("Yay! The token is valid")
                    }
                case .failure(let error):
                    print("Failed with \(error)")
                }
        }
    }
}
