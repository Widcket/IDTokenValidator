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
    case token1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjoxNTY4MDk2MDQyLCJleHAiOjIwNzMzNDY3Mzh9.lMKzXXCdQA3uFP5ONh1LrmKF0NouRh-Ys-q_aFeN1Ek"
    case token2 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfEFCQzEyMyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjoxNTY4MDk2MDQyLCJleHAiOjIwNzMzNDY3Mzh9.PiwyB1RwCuvRzQorjX7XUL1PIIGpE1PL1AR1xAJIl2w"
    case token3 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwOi8vZXhhbXBsZS5jb20vIiwic3ViIjoiYXV0aDB8YWJjMTIzIiwiYXVkIjoiY2xpZW50SWQiLCJpYXQiOjE1NjgwOTYwNDIsImV4cCI6MjA3MzM0NjczOH0.W0ifqbzcMIJUmLNfBaw6lzh6mLaQC_Io-TPUdtnNbgg"
}

private enum InvalidTokens: String, CaseIterable {
    case invalidIss = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJleGFtcGxlIiwic3ViIjoiYXV0aDB8YWJjMTIzIiwiYXVkIjoiY2xpZW50SWQiLCJpYXQiOjE1NjgwOTYwNDIsImV4cCI6MjA3MzM0NjczOH0.IHwbDNzqAN0qaVZuvEBSyUZhoUYTu2eCAgGXWMXk0xQ"
    case missingIss = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhdXRoMHxhYmMxMjMiLCJhdWQiOiJjbGllbnRJZCIsImlhdCI6MTU2ODA5NjA0MiwiZXhwIjoyMDczMzQ2NzM4fQ.k_n0ojT13LpH08hsCjaYiGQyQi-YC6Tu5B1Y5Qc-Zds"
    case invalidSub = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjoxNTY4MDk2MDQyLCJleHAiOjIwNzMzNDY3Mzh9.KoE9rTfzg2utFy-um1nmKkbBV0K3TWuOO-3e1KPmk-0"
    case missingSub = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjoxNTY4MDk2MDQyLCJleHAiOjIwNzMzNDY3Mzh9.RTff4bYtZlEo1v5ZUVWM8_u_cOenQQ1gtD8Hyw1GJxU"
    case invalidAud = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImF1ZCIsImlhdCI6MTU2ODA5NjA0MiwiZXhwIjoyMDczMzQ2NzM4fQ.5kSpfW1RDwcH3nHztDDUVutH4_08VvTAlnvT9Ys2-tM"
    case missingAud = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImlhdCI6MTU2ODA5NjA0MiwiZXhwIjoyMDczMzQ2NzM4fQ.4CuSzA9k49UIorVCWtZwOPES_my3CUKb3LvzzzWCU3k"
    case invalidIat = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjotMTIzLCJleHAiOjIwNzMzNDY3Mzh9.H9lpYXljy7p-Q0sg_jAgyEyP3FhL1gdw23OGwjlyCfg"
    case missingIat = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiZXhwIjoyMDczMzQ2NzM4fQ.Jr67b2MOAWo4i5ArgP4CpgwXBvARlFx24hI1ZiyWrBI"
    case invalidExp = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjoxNTY4MDk2MDQyLCJleHAiOjE1Njg0MjUzOTZ9.GbuLqnnkDk-mh2J0meI6V78_KL8RkabxdfPAk9wVBAw"
    case missingExp = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tLyIsInN1YiI6ImF1dGgwfGFiYzEyMyIsImF1ZCI6ImNsaWVudElkIiwiaWF0IjoxNTY4MDk2MDQyfQ.SwXhxDb36S6GABnR3yMM5igyQ8KciR3NYdQztzYdlGk"
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
                        expect($0?.iat).to(beGreaterThan(1567321702))
                        expect($0?.exp).to(beGreaterThan(1568427208))
                    }
                }
            }
            
            context("given a structurally valid token") {
                it("should extract the claims") {
                    let tokens: [InvalidTokens] = [.invalidIss,
                                                   .invalidSub,
                                                   .invalidAud,
                                                   .invalidIat,
                                                   .invalidExp]
                        
                    tokens.map{ Claims($0.rawValue) }.forEach {
                        expect($0).toNot(beNil())
                        expect($0?.iss).toNot(beEmpty())
                        expect($0?.sub).toNot(beEmpty())
                        expect($0?.aud).toNot(beEmpty())
                        expect($0?.iat).to(beLessThan(1568427208))
                        expect($0?.exp).to(beGreaterThan(1568340808))
                    }
                }
            }
            
            context("given a structurally invalid token") {
                it("should return nil") {
                    let tokens: [InvalidTokens] = [.missingIss,
                                                   .missingSub,
                                                   .missingAud,
                                                   .missingIat,
                                                   .missingExp,
                                                   .dummy]
                    
                    tokens.map{ Claims($0.rawValue) }.forEach {
                        expect($0).to(beNil())
                    }
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
                    let invalidIatClaims = Claims(InvalidTokens.invalidIat.rawValue),
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
                
                it("should return false for an invalid iat") {
                    expect(ClaimsValidator(credentials).validate(invalidIatClaims)).to(beFalse())
                }
                
                it("should return false for an invalid exp") {
                    expect(ClaimsValidator(credentials).validate(invalidExpClaims)).to(beFalse())
                }
            }
        }
    }
}
