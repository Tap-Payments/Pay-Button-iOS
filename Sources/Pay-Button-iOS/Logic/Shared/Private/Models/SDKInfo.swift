// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let sDKInfo = try SDKInfo(json)

import Foundation

// MARK: - SDKInfo
struct SDKInfo: Codable {
    var sdkInfo: SDKInfoClass?

    enum CodingKeys: String, CodingKey {
        case sdkInfo = "sdk_info"
    }
}

// MARK: SDKInfo convenience initializers and mutators

extension SDKInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SDKInfo.self, from: data)
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
        sdkInfo: SDKInfoClass?? = nil
    ) -> SDKInfo {
        return SDKInfo(
            sdkInfo: sdkInfo ?? self.sdkInfo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SDKInfoClass
struct SDKInfoClass: Codable {
    var type, version, authorization, mdn: String?
    var application: String?
}

// MARK: SDKInfoClass convenience initializers and mutators

extension SDKInfoClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SDKInfoClass.self, from: data)
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
        type: String?? = nil,
        version: String?? = nil,
        authorization: String?? = nil,
        mdn: String?? = nil,
        application: String?? = nil
    ) -> SDKInfoClass {
        return SDKInfoClass(
            type: type ?? self.type,
            version: version ?? self.version,
            authorization: authorization ?? self.authorization,
            mdn: mdn ?? self.mdn,
            application: application ?? self.application
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
