//
//  IDTokenValidatorTests.swift
//  IDTokenValidatorTests
//
//  Created by Rita Zerrizuela on 10/09/2019.
//  Copyright © 2019 Rita Zerrizuela. All rights reserved.
//

import Quick
import Nimble

@testable import IDTokenValidator

private enum ValidTokens: String, CaseIterable {
    case token1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiZXhwIjoyMDczMzQ2NzM4fQ.Jr67b2MOAWo4i5ArgP4CpgwXBvARlFx24hI1ZiyWrBI"
    case token2 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfEFCQzEyMyIsImF1ZCI6ImNsaWVudElkIiwiZXhwIjoyMDczMzQ2NzM4fQ.SoDR2U-PBJHXx1gA9Ab3mcHUda0BqTXuubLtOiva-u8"
    case token3 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwOi8vZXhhbXBsZS5jb20vIiwic3ViIjoiYXV0aDB8YWJjMTIzIiwiYXVkIjoiY2xpZW50SWQiLCJleHAiOjIwNzMzNDY3Mzh9.XROSxRTj-kxxsrIaPCJsu9Nn4BS8e55xqP98KLcE5oo"
}

private enum InvalidTokens: String, CaseIterable {
    case invalidIss = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJleGFtcGxlIiwic3ViIjoiYXV0aDB8YWJjMTIzIiwiYXVkIjoiY2xpZW50SWQiLCJleHAiOjIwNzMzNDY3Mzh9.pzRkTWZyvi0gpxQcUruzU7NuBlGw4IoGDzoOx4F7fAo"
    case invalidSub = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiZXhwIjoyMDczMzQ2NzM4fQ.V8a7iuTeTdi3RxUde9sLSfE9P0lu7-OzOFxS8OloZBE"
    case invalidAud = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImF1ZCIsImV4cCI6MjA3MzM0NjczOH0.ifq_ltQ5Yg3Pms1lbq0PiJdrsTML2niqzepkKM57Vaw"
    case invalidExp = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiZXhwIjoxNTY4NDI1Mzk2fQ.8qABNB8IbKCsZYdB-ccUsNkl5iXudAN7AhsSqBBhLWk"
    case dummy = "not-a-token"
}

class IDTokenValidatorTests: QuickSpec {
    override func spec() {
        let bundle = Bundle(for: type(of: self))
        
        describe("IDTokenValidator") {
            context("given a valid token") {
                it("should return true") {
                    ValidTokens.allCases.forEach {
                        expect(IDTokenValidator.validate($0.rawValue, bundle: bundle)).to(beTrue())
                    }
                }
            }
            
            context("given an invalid token") {
                it("should return false") {
                    InvalidTokens.allCases.forEach {
                        expect(IDTokenValidator.validate($0.rawValue, bundle: bundle)).to(beFalse())
                    }
                }
            }
        }
        
        describe("Claims") {
            context("given a valid token") {
                it("should extract the claims") {
                    ValidTokens.allCases.map{ Claims($0.rawValue) }.forEach {
                        expect($0).toNot(beNil())
                        expect($0?.iss).toNot(beEmpty())
                        expect($0?.sub).toNot(beEmpty())
                        expect($0?.aud).toNot(beEmpty())
                        expect($0?.exp).to(beGreaterThan(1568427208))
                    }
                }
            }
            
            context("given a structurally valid token") {
                it("should extract the claims") {
                    let tokens: [InvalidTokens] = [.invalidIss, .invalidSub, .invalidAud, .invalidExp]
                        
                    tokens.map{ Claims($0.rawValue) }.forEach {
                        expect($0).toNot(beNil())
                        expect($0?.iss).toNot(beEmpty())
                        expect($0?.sub).toNot(beEmpty())
                        expect($0?.aud).toNot(beEmpty())
                        expect($0?.exp).to(beGreaterThan(1568340808))
                    }
                }
            }
            
            context("given a structurally invalid token") {
                it("should return nil") {
                    let claims = Claims(InvalidTokens.dummy.rawValue)
                    
                    expect(claims).to(beNil())
                }
            }
        }
        
        describe("Credentials") {
            context("given a bundle with a valid credentials file") {
                it("should extract the credentials") {
                    let credentials = Credentials(bundle, plist: "ValidCredentials")
                    
                    expect(credentials).toNot(beNil())
                    expect(credentials?.clientId).to(equal("clientId"))
                    expect(credentials?.domain).to(equal("example.com"))
                }
            }
            
            context("given a bundle with an invalid credentials file") {
                it("should return nil") {
                    let credentials = Credentials(bundle, plist: "InvalidCredentials")
                    
                    expect(credentials).to(beNil())
                }
            }
        }
        
        describe("ClaimsValidator") {
            guard let credentials = Credentials(bundle) else {
                fail("failed to extract creentials")
                
                return
            }
            
            context("given valid claims") {
                it("should return true") {
                    ValidTokens.allCases.compactMap{ Claims($0.rawValue) }.forEach {
                        expect(ClaimsValidator(credentials).validate($0)).to(beTrue())
                    }
                }
            }
            
            context("given invalid claims") {
                guard let invalidIssClaims = Claims(InvalidTokens.invalidIss.rawValue),
                    let invalidSubClaims = Claims(InvalidTokens.invalidSub.rawValue),
                    let invalidAudClaims = Claims(InvalidTokens.invalidAud.rawValue),
                    let invalidExpClaims = Claims(InvalidTokens.invalidExp.rawValue) else {
                        fail("failed to extract claims")
                    
                        return
                }
                
                it("should return false for an invalid iss") {
                    expect(ClaimsValidator(credentials).validate(invalidIssClaims)).to(beFalse())
                }
                
                it("should return false for an invalid sub") {
                    expect(ClaimsValidator(credentials).validate(invalidSubClaims)).to(beFalse())
                }
                
                it("should return false for an invalid aud") {
                    expect(ClaimsValidator(credentials).validate(invalidAudClaims)).to(beFalse())
                }
                
                it("should return false for an invalid exp") {
                    expect(ClaimsValidator(credentials).validate(invalidExpClaims)).to(beFalse())
                }
            }
        }
    }
}
