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
    /// Whether or not we shall do the redirection
    var stopRedirection:Bool?
}

// MARK: - CardRedirection
/// The model the card web sdk sends with `on3dsRedirect`, when the payer has to be authenticated.
/// Same shape Card-iOS decodes, the card form behind the button is the same web sdk.
internal struct CardRedirection: Codable {
    /// The 3DS/Otp page link we need to display
    var threeDsUrl: String?
    /// The url we need to listen to, to detect the end of the authentication process
    var redirectUrl: String?
    /// The query parameter we watch for on the loaded pages to know the process is done
    var keyword: String?
    /// Whether or not we shall show the powered by tap flag
    var powered: Bool?
}

extension CardRedirection {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CardRedirection.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
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
        powered: Bool?? = true,
        stopRedirection: Bool?? = false
    ) -> Redirection {
        return Redirection(
            url: threeDsUrl ?? self.url,
            id: id ?? self.id,
            powered: powered ?? self.powered,
            stopRedirection: stopRedirection ?? self.stopRedirection
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
