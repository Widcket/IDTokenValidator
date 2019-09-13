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
        // Check if the token is nil or malformed
        guard let idToken = idToken, let claims = Claims(idToken) else { return false }
        
        guard let credentials = Credentials(bundle) else {
            fatalError("Could not find Auth0.plist")
        }
        
        return ClaimsValidator(credentials).validate(claims)
    }
}

private struct Claims {
    let iss: String
    let aud: String
    let sub: String
    let exp: Double
    
    init?(_ idToken: String) {
        // From https://github.com/auth0/Auth0.swift/blob/master/Auth0/OAuth2Grant.swift
        
        let splitToken = idToken.split(separator: ".")
        
        guard splitToken.count == 3 else { return nil }
        
        var base64 = splitToken[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = Int(requiredLength - length)
        
        if paddingLength > 0 {
            base64 += "".padding(toLength: paddingLength, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
            let body = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let iss = body["iss"] as? String,
            let aud = body["aud"] as? String,
            let sub = body["sub"] as? String,
            let exp = body["exp"] as? Double else { return nil }
        
        self.iss = iss
        self.aud = aud
        self.sub = sub
        self.exp = exp
    }
}

private struct Credentials {
    let clientId: String
    let domain: String
    
    init?(_ bundle: Bundle) {
        guard let path = bundle.path(forResource: "Auth0", ofType: "plist"),
            let credentials = NSDictionary(contentsOfFile: path),
            let clientId = credentials["ClientId"] as? String,
            let domain = credentials["Domain"] as? String else { return nil }
 
        self.clientId = clientId
        self.domain = domain
    }
}

private class ClaimsValidator {
    private let credentials: Credentials
    
    init(_ credentials: Credentials) {
        self.credentials = credentials
    }
    
    private func validateIss(_ iss: String) -> Bool {
        guard let url = URL(string: iss), let host = url.host else { return false }
        
        return host == credentials.domain
    }
    
    private func validateAud(_ aud: String) -> Bool {
        return aud == credentials.clientId
    }
    
    private func validateSub(_ sub: String) -> Bool {
        let splitSub = sub.split(separator: "|")
        
        guard let auth0 = splitSub.first, let userId = splitSub.last else { return false }
        
        let alphanumericCharset = CharacterSet.decimalDigits.union(CharacterSet.lowercaseLetters)
        let userIdCharset = CharacterSet(charactersIn: String(userId.lowercased()))
        
        return auth0 == "auth0" &&
            !userId.isEmpty &&
            alphanumericCharset.isSuperset(of: userIdCharset)
    }
    
    private func validateExp(_ exp: Double) -> Bool {
        // 5 minutes of leeway for server time
        return Date(timeIntervalSince1970: exp) > Date().addingTimeInterval(5.0 * 60.0)
    }
    
    func validate(_ claims: Claims) -> Bool {
        return validateIss(claims.iss) &&
            validateAud(claims.aud) &&
            validateSub(claims.sub) &&
            validateExp(claims.exp)
    }
}
