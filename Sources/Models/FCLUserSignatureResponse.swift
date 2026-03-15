//
//  FCLUserSignatureResponse.swift
//  FCL
//
//  Created by Nicholas Reich on 3/14/26.
//


// Models/FCLUserSignatureResponse.swift

import Foundation

public struct FCLUserSignatureResponse: Codable {
    public let addr: String
    public let keyId: Int
    public let signature: String

    public init(addr: String, keyId: Int, signature: String) {
        self.addr = addr
        self.keyId = keyId
        self.signature = signature
    }
}
