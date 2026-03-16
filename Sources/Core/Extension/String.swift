import Foundation

public extension String {
    func toHex() -> String {
        return data(using: .utf8)!.map { String(format: "%02x", $0) }.joined()
    }

    func fromHex() -> String? {
        guard count % 2 == 0 else { return nil }

        var result = ""
        var start = startIndex

        while start < endIndex {
            let end = index(start, offsetBy: 2)
            if let byte = UInt8(self[start..<end], radix: 16) {
                result.append(Character(UnicodeScalar(byte)))
            }
            start = end
        }

        return result
    }

    var isValidFlowAddress: Bool {
        return count == 18 && hasPrefix("0x") && dropFirst(2).allSatisfy { $0.isHexDigit }
    }
}
