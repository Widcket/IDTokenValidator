//
//  IDTokenValidator.swift
//  IDTokenValidator
//
//  Created by Rita Zerrizuela on 11/09/2019.
//  Copyright © 2019 Rita Zerrizuela. All rights reserved.
//

import Foundation

public class IDTokenValidator {
    private init() {}
    
    /**
     
     */
    public static func validate(_ idToken: String?, bundle: Bundle = Bundle.main) -> Bool {
        // 1. clientID == aud
        // 2. domain host == iss
        // 2. sub split by pipe begins with "auth0" and ends in a valid uuid
        // 3. exp not expired yet
        
        // Token is nil or malformed
        guard let idToken = idToken, let claims = Claims(idToken) else {
            return false
        }
        
        guard let credentials = Credentials(bundle: bundle) else {
            fatalError("Could not find Auth0.plist")
        }
        
        return ClaimsValidator(credentials).validate(claims)
    }
}

private struct Claims {
    let iss: String
    let aud: String
    let sub: String
    let exp: String
    
    init?(_ idToken: String) {
        self.iss = ""
        self.aud = ""
        self.sub = ""
        self.exp = ""
    }
}

private struct Credentials {
    let clientId: String
    let domain: URL
    
    init?(bundle: Bundle) {
        self.clientId = ""
        self.domain = URL(string: "https://widcket.auth0.com")!
    }
}

private class ClaimsValidator {
    private let credentials: Credentials
    
    init(_ credentials: Credentials) {
        self.credentials = credentials
    }
    
    private func validateIss(_ iss: String) -> Bool {
        return true
    }
    
    private func validateAud(_ aud: String) -> Bool {
        return true
    }
    
    private func validateSub(_ sub: String) -> Bool {
        return true
    }
    
    private func validateExp(_ exp: String) -> Bool {
        return true
    }
    
    func validate(_ claims: Claims) -> Bool {
        return validateIss(claims.iss) &&
            validateAud(claims.aud) &&
            validateSub(claims.sub) &&
            validateExp(claims.exp)
    }
}
