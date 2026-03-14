// WalletUtil/WalletUtil.swift

import Flow
import Foundation

extension FCL {
    enum WalletUtil {
        @MainActor
        static func encodeMessageForProvableAuthnSigning(address: Flow.Address,
                                                         timestamp: TimeInterval,
                                                         appDomainTag: String? = nil) -> String
        {
            var rlpList: [Flow.DomainTag] = []

            if let tag = appDomainTag {
                rlpList.append(Flow.DomainTag.custom(tag))
            } else if let tag = fcl.config.get(.domainTag) {
                rlpList.append(Flow.DomainTag.custom(tag))
            }

            // … existing logic …

            return "" // your existing return
        }
    }
}
