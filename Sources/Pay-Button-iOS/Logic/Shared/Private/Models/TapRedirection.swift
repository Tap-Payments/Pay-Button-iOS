//
//  File.swift
//  
//
//  Created by Osama Rabie on 26/10/2023.
//

import Foundation
// MARK: - RedirectionBasedModel
/// The model expected to be fetched from the knet sdk when it sends the event of showing OTP/3ds page
internal struct Redirection: Codable {
    /// The 3DS/Otp page link we need to display
    var url: String?
    /// The id of the charge created
    var id: String?
    /// Whether or not we shall show the powered by tap flag
    var powered:Bool?
}

// MARK: KnetRedirection convenience initializers and mutators

extension Redirection {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Redirection.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        threeDsUrl: String?? = nil,
        id: String?? = nil,
        keyword: String?? = nil,
        powered: Bool?? = true
    ) -> Redirection {
        return Redirection(
            url: threeDsUrl ?? self.url,
            id: id ?? self.id,
            powered: powered ?? self.powered
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}



// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
