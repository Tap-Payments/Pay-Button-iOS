// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let intentRequest = try IntentRequest(json)

import Foundation

// MARK: - IntentRequest
struct IntentRequest: Codable {
    var scope, purpose, statementDescriptor, reference: String?
    var customerInitiated: Bool?
    var hashString, idempotent: String?
    var merchant: Merchant?
    var authenticate: Authenticate?
    var destinations: Destinations?
    var topup: Topup?
    var transaction: Transaction?
    var invoice: Invoice?
    var order: Order?
    var customer: Customer?
    var receipt: Receipt?
    var config: Config?
    var domain, redirect, post: Domain?
    var checkout: Checkout?

    enum CodingKeys: String, CodingKey {
        case scope, purpose
        case statementDescriptor = "statement_descriptor"
        case reference
        case customerInitiated = "customer_initiated"
        case hashString = "hash_string"
        case idempotent, merchant, authenticate, destinations, topup, transaction, invoice, order, customer, receipt, config, domain, redirect, post, checkout
    }
}

// MARK: IntentRequest convenience initializers and mutators

extension IntentRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IntentRequest.self, from: data)
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
        scope: String?? = nil,
        purpose: String?? = nil,
        statementDescriptor: String?? = nil,
        reference: String?? = nil,
        customerInitiated: Bool?? = nil,
        hashString: String?? = nil,
        idempotent: String?? = nil,
        merchant: Merchant?? = nil,
        authenticate: Authenticate?? = nil,
        destinations: Destinations?? = nil,
        topup: Topup?? = nil,
        transaction: Transaction?? = nil,
        invoice: Invoice?? = nil,
        order: Order?? = nil,
        customer: Customer?? = nil,
        receipt: Receipt?? = nil,
        config: Config?? = nil,
        domain: Domain?? = nil,
        redirect: Domain?? = nil,
        post: Domain?? = nil,
        checkout: Checkout?? = nil
    ) -> IntentRequest {
        return IntentRequest(
            scope: scope ?? self.scope,
            purpose: purpose ?? self.purpose,
            statementDescriptor: statementDescriptor ?? self.statementDescriptor,
            reference: reference ?? self.reference,
            customerInitiated: customerInitiated ?? self.customerInitiated,
            hashString: hashString ?? self.hashString,
            idempotent: idempotent ?? self.idempotent,
            merchant: merchant ?? self.merchant,
            authenticate: authenticate ?? self.authenticate,
            destinations: destinations ?? self.destinations,
            topup: topup ?? self.topup,
            transaction: transaction ?? self.transaction,
            invoice: invoice ?? self.invoice,
            order: order ?? self.order,
            customer: customer ?? self.customer,
            receipt: receipt ?? self.receipt,
            config: config ?? self.config,
            domain: domain ?? self.domain,
            redirect: redirect ?? self.redirect,
            post: post ?? self.post,
            checkout: checkout ?? self.checkout
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Authenticate
struct Authenticate: Codable {
    var id: String?
    var authenticateRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case authenticateRequired = "required"
    }
}

// MARK: Authenticate convenience initializers and mutators

extension Authenticate {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Authenticate.self, from: data)
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
        id: String?? = nil,
        authenticateRequired: Bool?? = nil
    ) -> Authenticate {
        return Authenticate(
            id: id ?? self.id,
            authenticateRequired: authenticateRequired ?? self.authenticateRequired
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Checkout
struct Checkout: Codable {
    var auto: Bool?
    var metadata: CheckoutMetadata?
}

// MARK: Checkout convenience initializers and mutators

extension Checkout {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Checkout.self, from: data)
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
        auto: Bool?? = nil,
        metadata: CheckoutMetadata?? = nil
    ) -> Checkout {
        return Checkout(
            auto: auto ?? self.auto,
            metadata: metadata ?? self.metadata
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CheckoutMetadata
struct CheckoutMetadata: Codable {
    var udf1, udf2: String?
}

// MARK: CheckoutMetadata convenience initializers and mutators

extension CheckoutMetadata {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CheckoutMetadata.self, from: data)
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
        udf1: String?? = nil,
        udf2: String?? = nil
    ) -> CheckoutMetadata {
        return CheckoutMetadata(
            udf1: udf1 ?? self.udf1,
            udf2: udf2 ?? self.udf2
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Config
struct Config: Codable {
    var initiator, type: String?
    var features: Features?
    var acceptance: Acceptance?
    var fieldVisibility: FieldVisibility?
    var interface: Interface?

    enum CodingKeys: String, CodingKey {
        case initiator, type, features, acceptance
        case fieldVisibility = "field_visibility"
        case interface
    }
}

// MARK: Config convenience initializers and mutators

extension Config {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Config.self, from: data)
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
        initiator: String?? = nil,
        type: String?? = nil,
        features: Features?? = nil,
        acceptance: Acceptance?? = nil,
        fieldVisibility: FieldVisibility?? = nil,
        interface: Interface?? = nil
    ) -> Config {
        return Config(
            initiator: initiator ?? self.initiator,
            type: type ?? self.type,
            features: features ?? self.features,
            acceptance: acceptance ?? self.acceptance,
            fieldVisibility: fieldVisibility ?? self.fieldVisibility,
            interface: interface ?? self.interface
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Acceptance
struct Acceptance: Codable {
    var supportedRegions, supportedCountries, supportedCurrencies, supportedPaymentTypes: [String]?
    var supportedPaymentMethods, supportedSchemes, supportedFundSource, supportedPaymentAuthentications: [String]?
    var supportedPaymentFlows: [String]?

    enum CodingKeys: String, CodingKey {
        case supportedRegions = "supported_regions"
        case supportedCountries = "supported_countries"
        case supportedCurrencies = "supported_currencies"
        case supportedPaymentTypes = "supported_payment_types"
        case supportedPaymentMethods = "supported_payment_methods"
        case supportedSchemes = "supported_schemes"
        case supportedFundSource = "supported_fund_source"
        case supportedPaymentAuthentications = "supported_payment_authentications"
        case supportedPaymentFlows = "supported_payment_flows"
    }
}

// MARK: Acceptance convenience initializers and mutators

extension Acceptance {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Acceptance.self, from: data)
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
        supportedRegions: [String]?? = nil,
        supportedCountries: [String]?? = nil,
        supportedCurrencies: [String]?? = nil,
        supportedPaymentTypes: [String]?? = nil,
        supportedPaymentMethods: [String]?? = nil,
        supportedSchemes: [String]?? = nil,
        supportedFundSource: [String]?? = nil,
        supportedPaymentAuthentications: [String]?? = nil,
        supportedPaymentFlows: [String]?? = nil
    ) -> Acceptance {
        return Acceptance(
            supportedRegions: supportedRegions ?? self.supportedRegions,
            supportedCountries: supportedCountries ?? self.supportedCountries,
            supportedCurrencies: supportedCurrencies ?? self.supportedCurrencies,
            supportedPaymentTypes: supportedPaymentTypes ?? self.supportedPaymentTypes,
            supportedPaymentMethods: supportedPaymentMethods ?? self.supportedPaymentMethods,
            supportedSchemes: supportedSchemes ?? self.supportedSchemes,
            supportedFundSource: supportedFundSource ?? self.supportedFundSource,
            supportedPaymentAuthentications: supportedPaymentAuthentications ?? self.supportedPaymentAuthentications,
            supportedPaymentFlows: supportedPaymentFlows ?? self.supportedPaymentFlows
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Features
struct Features: Codable {
    var acceptanceBadge, order, multipleCurrencies: Bool?
    var currencyConversions: CurrencyConversions?
    var payments: Payments?
    var alternativeCardInputs: AlternativeCardInputs?
    var customerCards: CustomerCards?

    enum CodingKeys: String, CodingKey {
        case acceptanceBadge = "acceptance_badge"
        case order
        case multipleCurrencies = "multiple_currencies"
        case currencyConversions = "currency_conversions"
        case payments
        case alternativeCardInputs = "alternative_card_inputs"
        case customerCards = "customer_cards"
    }
}

// MARK: Features convenience initializers and mutators

extension Features {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Features.self, from: data)
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
        acceptanceBadge: Bool?? = nil,
        order: Bool?? = nil,
        multipleCurrencies: Bool?? = nil,
        currencyConversions: CurrencyConversions?? = nil,
        payments: Payments?? = nil,
        alternativeCardInputs: AlternativeCardInputs?? = nil,
        customerCards: CustomerCards?? = nil
    ) -> Features {
        return Features(
            acceptanceBadge: acceptanceBadge ?? self.acceptanceBadge,
            order: order ?? self.order,
            multipleCurrencies: multipleCurrencies ?? self.multipleCurrencies,
            currencyConversions: currencyConversions ?? self.currencyConversions,
            payments: payments ?? self.payments,
            alternativeCardInputs: alternativeCardInputs ?? self.alternativeCardInputs,
            customerCards: customerCards ?? self.customerCards
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - AlternativeCardInputs
struct AlternativeCardInputs: Codable {
    var cardScanner, cardNFC: Bool?

    enum CodingKeys: String, CodingKey {
        case cardScanner = "card_scanner"
        case cardNFC = "card_nfc"
    }
}

// MARK: AlternativeCardInputs convenience initializers and mutators

extension AlternativeCardInputs {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AlternativeCardInputs.self, from: data)
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
        cardScanner: Bool?? = nil,
        cardNFC: Bool?? = nil
    ) -> AlternativeCardInputs {
        return AlternativeCardInputs(
            cardScanner: cardScanner ?? self.cardScanner,
            cardNFC: cardNFC ?? self.cardNFC
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CurrencyConversions
struct CurrencyConversions: Codable {
    var currencyConversionsDynamic, location, payment, cobadge: Bool?

    enum CodingKeys: String, CodingKey {
        case currencyConversionsDynamic = "dynamic"
        case location, payment, cobadge
    }
}

// MARK: CurrencyConversions convenience initializers and mutators

extension CurrencyConversions {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CurrencyConversions.self, from: data)
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
        currencyConversionsDynamic: Bool?? = nil,
        location: Bool?? = nil,
        payment: Bool?? = nil,
        cobadge: Bool?? = nil
    ) -> CurrencyConversions {
        return CurrencyConversions(
            currencyConversionsDynamic: currencyConversionsDynamic ?? self.currencyConversionsDynamic,
            location: location ?? self.location,
            payment: payment ?? self.payment,
            cobadge: cobadge ?? self.cobadge
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CustomerCards
struct CustomerCards: Codable {
    var saveCard, autoSaveCard, displaySavedCards: Bool?

    enum CodingKeys: String, CodingKey {
        case saveCard = "save_card"
        case autoSaveCard = "auto_save_card"
        case displaySavedCards = "display_saved_cards"
    }
}

// MARK: CustomerCards convenience initializers and mutators

extension CustomerCards {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CustomerCards.self, from: data)
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
        saveCard: Bool?? = nil,
        autoSaveCard: Bool?? = nil,
        displaySavedCards: Bool?? = nil
    ) -> CustomerCards {
        return CustomerCards(
            saveCard: saveCard ?? self.saveCard,
            autoSaveCard: autoSaveCard ?? self.autoSaveCard,
            displaySavedCards: displaySavedCards ?? self.displaySavedCards
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Payments
struct Payments: Codable {
    var card, device, wallet, bnpl: Bool?
    var mobile, cash, redirect: Bool?
}

// MARK: Payments convenience initializers and mutators

extension Payments {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Payments.self, from: data)
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
        card: Bool?? = nil,
        device: Bool?? = nil,
        wallet: Bool?? = nil,
        bnpl: Bool?? = nil,
        mobile: Bool?? = nil,
        cash: Bool?? = nil,
        redirect: Bool?? = nil
    ) -> Payments {
        return Payments(
            card: card ?? self.card,
            device: device ?? self.device,
            wallet: wallet ?? self.wallet,
            bnpl: bnpl ?? self.bnpl,
            mobile: mobile ?? self.mobile,
            cash: cash ?? self.cash,
            redirect: redirect ?? self.redirect
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FieldVisibility
struct FieldVisibility: Codable {
    var name: Bool?
    var card: Card?
    var contact: FieldVisibilityContact?
    var shipping: FieldVisibilityShipping?
}

// MARK: FieldVisibility convenience initializers and mutators

extension FieldVisibility {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FieldVisibility.self, from: data)
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
        name: Bool?? = nil,
        card: Card?? = nil,
        contact: FieldVisibilityContact?? = nil,
        shipping: FieldVisibilityShipping?? = nil
    ) -> FieldVisibility {
        return FieldVisibility(
            name: name ?? self.name,
            card: card ?? self.card,
            contact: contact ?? self.contact,
            shipping: shipping ?? self.shipping
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Card
struct Card: Codable {
    var number, expiry, cvv, cardholder: Bool?
}

// MARK: Card convenience initializers and mutators

extension Card {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Card.self, from: data)
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
        number: Bool?? = nil,
        expiry: Bool?? = nil,
        cvv: Bool?? = nil,
        cardholder: Bool?? = nil
    ) -> Card {
        return Card(
            number: number ?? self.number,
            expiry: expiry ?? self.expiry,
            cvv: cvv ?? self.cvv,
            cardholder: cardholder ?? self.cardholder
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FieldVisibilityContact
struct FieldVisibilityContact: Codable {
    var email, number: Bool?
}

// MARK: FieldVisibilityContact convenience initializers and mutators

extension FieldVisibilityContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FieldVisibilityContact.self, from: data)
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
        email: Bool?? = nil,
        number: Bool?? = nil
    ) -> FieldVisibilityContact {
        return FieldVisibilityContact(
            email: email ?? self.email,
            number: number ?? self.number
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FieldVisibilityShipping
struct FieldVisibilityShipping: Codable {
    var address: Bool?
}

// MARK: FieldVisibilityShipping convenience initializers and mutators

extension FieldVisibilityShipping {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FieldVisibilityShipping.self, from: data)
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
        address: Bool?? = nil
    ) -> FieldVisibilityShipping {
        return FieldVisibilityShipping(
            address: address ?? self.address
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Interface
struct Interface: Codable {
    var userExperience, locale, direction, cardDirection: String?
    var edges, theme, colorStyle: String?
    var loader, powered: Bool?

    enum CodingKeys: String, CodingKey {
        case userExperience = "user_experience"
        case locale, direction
        case cardDirection = "card_direction"
        case edges, theme
        case colorStyle = "color_style"
        case loader, powered
    }
}

// MARK: Interface convenience initializers and mutators

extension Interface {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Interface.self, from: data)
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
        userExperience: String?? = nil,
        locale: String?? = nil,
        direction: String?? = nil,
        cardDirection: String?? = nil,
        edges: String?? = nil,
        theme: String?? = nil,
        colorStyle: String?? = nil,
        loader: Bool?? = nil,
        powered: Bool?? = nil
    ) -> Interface {
        return Interface(
            userExperience: userExperience ?? self.userExperience,
            locale: locale ?? self.locale,
            direction: direction ?? self.direction,
            cardDirection: cardDirection ?? self.cardDirection,
            edges: edges ?? self.edges,
            theme: theme ?? self.theme,
            colorStyle: colorStyle ?? self.colorStyle,
            loader: loader ?? self.loader,
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

// MARK: - Customer
struct Customer: Codable {
    var id: String?
    var name: [Name]?
    var nameOnCard: NameOnCard?
    var contact: CustomerContact?
    var address: Address?

    enum CodingKeys: String, CodingKey {
        case id, name
        case nameOnCard = "name_on_card"
        case contact, address
    }
}

// MARK: Customer convenience initializers and mutators

extension Customer {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Customer.self, from: data)
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
        id: String?? = nil,
        name: [Name]?? = nil,
        nameOnCard: NameOnCard?? = nil,
        contact: CustomerContact?? = nil,
        address: Address?? = nil
    ) -> Customer {
        return Customer(
            id: id ?? self.id,
            name: name ?? self.name,
            nameOnCard: nameOnCard ?? self.nameOnCard,
            contact: contact ?? self.contact,
            address: address ?? self.address
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Address
struct Address: Codable {
    var type, line1, line2, line3: String?
    var line4, apartment, building, street: String?
    var avenue, block, area, city: String?
    var state, country, zipCode, postalCode: String?

    enum CodingKeys: String, CodingKey {
        case type, line1, line2, line3, line4, apartment, building, street, avenue, block, area, city, state, country
        case zipCode = "zip_code"
        case postalCode = "postal_code"
    }
}

// MARK: Address convenience initializers and mutators

extension Address {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Address.self, from: data)
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
        line1: String?? = nil,
        line2: String?? = nil,
        line3: String?? = nil,
        line4: String?? = nil,
        apartment: String?? = nil,
        building: String?? = nil,
        street: String?? = nil,
        avenue: String?? = nil,
        block: String?? = nil,
        area: String?? = nil,
        city: String?? = nil,
        state: String?? = nil,
        country: String?? = nil,
        zipCode: String?? = nil,
        postalCode: String?? = nil
    ) -> Address {
        return Address(
            type: type ?? self.type,
            line1: line1 ?? self.line1,
            line2: line2 ?? self.line2,
            line3: line3 ?? self.line3,
            line4: line4 ?? self.line4,
            apartment: apartment ?? self.apartment,
            building: building ?? self.building,
            street: street ?? self.street,
            avenue: avenue ?? self.avenue,
            block: block ?? self.block,
            area: area ?? self.area,
            city: city ?? self.city,
            state: state ?? self.state,
            country: country ?? self.country,
            zipCode: zipCode ?? self.zipCode,
            postalCode: postalCode ?? self.postalCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CustomerContact
struct CustomerContact: Codable {
    var email: String?
    var phone: Phone?
}

// MARK: CustomerContact convenience initializers and mutators

extension CustomerContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CustomerContact.self, from: data)
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
        email: String?? = nil,
        phone: Phone?? = nil
    ) -> CustomerContact {
        return CustomerContact(
            email: email ?? self.email,
            phone: phone ?? self.phone
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Phone
struct Phone: Codable {
    var countryCode, number: String?

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case number
    }
}

// MARK: Phone convenience initializers and mutators

extension Phone {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Phone.self, from: data)
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
        countryCode: String?? = nil,
        number: String?? = nil
    ) -> Phone {
        return Phone(
            countryCode: countryCode ?? self.countryCode,
            number: number ?? self.number
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Name
struct Name: Codable {
    var first, last, middle, title: String?
}

// MARK: Name convenience initializers and mutators

extension Name {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Name.self, from: data)
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
        first: String?? = nil,
        last: String?? = nil,
        middle: String?? = nil,
        title: String?? = nil
    ) -> Name {
        return Name(
            first: first ?? self.first,
            last: last ?? self.last,
            middle: middle ?? self.middle,
            title: title ?? self.title
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - NameOnCard
struct NameOnCard: Codable {
    var content: String?
    var editable: Bool?
}

// MARK: NameOnCard convenience initializers and mutators

extension NameOnCard {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NameOnCard.self, from: data)
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
        content: String?? = nil,
        editable: Bool?? = nil
    ) -> NameOnCard {
        return NameOnCard(
            content: content ?? self.content,
            editable: editable ?? self.editable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Destinations
struct Destinations: Codable {
    var retailer: [Retailer]?
}

// MARK: Destinations convenience initializers and mutators

extension Destinations {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Destinations.self, from: data)
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
        retailer: [Retailer]?? = nil
    ) -> Destinations {
        return Destinations(
            retailer: retailer ?? self.retailer
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Retailer
struct Retailer: Codable {
    var to: String?
    var amount: Int?
    var currency, description: String?
    var applicationFee: ApplicationFee?
    var reference: String?

    enum CodingKeys: String, CodingKey {
        case to, amount, currency, description
        case applicationFee = "application_fee"
        case reference
    }
}

// MARK: Retailer convenience initializers and mutators

extension Retailer {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Retailer.self, from: data)
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
        to: String?? = nil,
        amount: Int?? = nil,
        currency: String?? = nil,
        description: String?? = nil,
        applicationFee: ApplicationFee?? = nil,
        reference: String?? = nil
    ) -> Retailer {
        return Retailer(
            to: to ?? self.to,
            amount: amount ?? self.amount,
            currency: currency ?? self.currency,
            description: description ?? self.description,
            applicationFee: applicationFee ?? self.applicationFee,
            reference: reference ?? self.reference
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ApplicationFee
struct ApplicationFee: Codable {
    var amount: Int?
    var apply: Bool?
}

// MARK: ApplicationFee convenience initializers and mutators

extension ApplicationFee {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ApplicationFee.self, from: data)
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
        amount: Int?? = nil,
        apply: Bool?? = nil
    ) -> ApplicationFee {
        return ApplicationFee(
            amount: amount ?? self.amount,
            apply: apply ?? self.apply
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Domain
struct Domain: Codable {
    var url: String?
}

// MARK: Domain convenience initializers and mutators

extension Domain {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Domain.self, from: data)
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
        url: String?? = nil
    ) -> Domain {
        return Domain(
            url: url ?? self.url
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Invoice
struct Invoice: Codable {
    var id: String?
}

// MARK: Invoice convenience initializers and mutators

extension Invoice {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Invoice.self, from: data)
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
        id: String?? = nil
    ) -> Invoice {
        return Invoice(
            id: id ?? self.id
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Merchant
struct Merchant: Codable {
    var id: String?
    var terminal: Terminal?
    var merchantOperator: Operator?
    var paymentProvider: PaymentProvider?
    var developmentHouse, platform: Invoice?

    enum CodingKeys: String, CodingKey {
        case id, terminal
        case merchantOperator = "operator"
        case paymentProvider = "payment_provider"
        case developmentHouse = "development_house"
        case platform
    }
}

// MARK: Merchant convenience initializers and mutators

extension Merchant {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Merchant.self, from: data)
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
        id: String?? = nil,
        terminal: Terminal?? = nil,
        merchantOperator: Operator?? = nil,
        paymentProvider: PaymentProvider?? = nil,
        developmentHouse: Invoice?? = nil,
        platform: Invoice?? = nil
    ) -> Merchant {
        return Merchant(
            id: id ?? self.id,
            terminal: terminal ?? self.terminal,
            merchantOperator: merchantOperator ?? self.merchantOperator,
            paymentProvider: paymentProvider ?? self.paymentProvider,
            developmentHouse: developmentHouse ?? self.developmentHouse,
            platform: platform ?? self.platform
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Operator
struct Operator: Codable {
    var id: String?
    var device: Invoice?
}

// MARK: Operator convenience initializers and mutators

extension Operator {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Operator.self, from: data)
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
        id: String?? = nil,
        device: Invoice?? = nil
    ) -> Operator {
        return Operator(
            id: id ?? self.id,
            device: device ?? self.device
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - PaymentProvider
struct PaymentProvider: Codable {
    var technology, institution: Invoice?
}

// MARK: PaymentProvider convenience initializers and mutators

extension PaymentProvider {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PaymentProvider.self, from: data)
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
        technology: Invoice?? = nil,
        institution: Invoice?? = nil
    ) -> PaymentProvider {
        return PaymentProvider(
            technology: technology ?? self.technology,
            institution: institution ?? self.institution
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Terminal
struct Terminal: Codable {
    var id: String?
    var terminalDevice: Invoice?

    enum CodingKeys: String, CodingKey {
        case id
        case terminalDevice = "terminal_device"
    }
}

// MARK: Terminal convenience initializers and mutators

extension Terminal {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Terminal.self, from: data)
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
        id: String?? = nil,
        terminalDevice: Invoice?? = nil
    ) -> Terminal {
        return Terminal(
            id: id ?? self.id,
            terminalDevice: terminalDevice ?? self.terminalDevice
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Order
struct Order: Codable {
    var id: String?
    var amount: Double?
    var currency: String?
    var description: [Description]?
    var reference: String?
    var items: Items?
    var tax: [Tax]?
    var discount: Discount?
    var shipping: OrderShipping?
    var metadata: OrderMetadata?
}

// MARK: Order convenience initializers and mutators

extension Order {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Order.self, from: data)
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
        id: String?? = nil,
        amount: Double?? = nil,
        currency: String?? = nil,
        description: [Description]?? = nil,
        reference: String?? = nil,
        items: Items?? = nil,
        tax: [Tax]?? = nil,
        discount: Discount?? = nil,
        shipping: OrderShipping?? = nil,
        metadata: OrderMetadata?? = nil
    ) -> Order {
        return Order(
            id: id ?? self.id,
            amount: amount ?? self.amount,
            currency: currency ?? self.currency,
            description: description ?? self.description,
            reference: reference ?? self.reference,
            items: items ?? self.items,
            tax: tax ?? self.tax,
            discount: discount ?? self.discount,
            shipping: shipping ?? self.shipping,
            metadata: metadata ?? self.metadata
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Description
struct Description: Codable {
    var text, lang: String?
}

// MARK: Description convenience initializers and mutators

extension Description {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Description.self, from: data)
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
        text: String?? = nil,
        lang: String?? = nil
    ) -> Description {
        return Description(
            text: text ?? self.text,
            lang: lang ?? self.lang
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Discount
struct Discount: Codable {
    var type: String?
    var value: Int?
}

// MARK: Discount convenience initializers and mutators

extension Discount {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Discount.self, from: data)
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
        value: Int?? = nil
    ) -> Discount {
        return Discount(
            type: type ?? self.type,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Items
struct Items: Codable {
    var count: Int?
    var list: [List]?
}

// MARK: Items convenience initializers and mutators

extension Items {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Items.self, from: data)
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
        count: Int?? = nil,
        list: [List]?? = nil
    ) -> Items {
        return Items(
            count: count ?? self.count,
            list: list ?? self.list
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - List
struct List: Codable {
    var id: String?
    var quantity: Int?
    var pickup: Bool?
    var product: Product?
}

// MARK: List convenience initializers and mutators

extension List {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(List.self, from: data)
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
        id: String?? = nil,
        quantity: Int?? = nil,
        pickup: Bool?? = nil,
        product: Product?? = nil
    ) -> List {
        return List(
            id: id ?? self.id,
            quantity: quantity ?? self.quantity,
            pickup: pickup ?? self.pickup,
            product: product ?? self.product
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Product
struct Product: Codable {
    var id: String?
    var amount: Int?
    var name, description: [Description]?
    var category: String?
    var metadata: ProductMetadata?
    var reference: Reference?
}

// MARK: Product convenience initializers and mutators

extension Product {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Product.self, from: data)
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
        id: String?? = nil,
        amount: Int?? = nil,
        name: [Description]?? = nil,
        description: [Description]?? = nil,
        category: String?? = nil,
        metadata: ProductMetadata?? = nil,
        reference: Reference?? = nil
    ) -> Product {
        return Product(
            id: id ?? self.id,
            amount: amount ?? self.amount,
            name: name ?? self.name,
            description: description ?? self.description,
            category: category ?? self.category,
            metadata: metadata ?? self.metadata,
            reference: reference ?? self.reference
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ProductMetadata
struct ProductMetadata: Codable {
    var empty: String?

    enum CodingKeys: String, CodingKey {
        case empty = ""
    }
}

// MARK: ProductMetadata convenience initializers and mutators

extension ProductMetadata {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ProductMetadata.self, from: data)
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
        empty: String?? = nil
    ) -> ProductMetadata {
        return ProductMetadata(
            empty: empty ?? self.empty
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Reference
struct Reference: Codable {
    var sku, gtin, code, financialCode: String?

    enum CodingKeys: String, CodingKey {
        case sku, gtin, code
        case financialCode = "financial_code"
    }
}

// MARK: Reference convenience initializers and mutators

extension Reference {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Reference.self, from: data)
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
        sku: String?? = nil,
        gtin: String?? = nil,
        code: String?? = nil,
        financialCode: String?? = nil
    ) -> Reference {
        return Reference(
            sku: sku ?? self.sku,
            gtin: gtin ?? self.gtin,
            code: code ?? self.code,
            financialCode: financialCode ?? self.financialCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - OrderMetadata
struct OrderMetadata: Codable {
    var o: String?
}

// MARK: OrderMetadata convenience initializers and mutators

extension OrderMetadata {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(OrderMetadata.self, from: data)
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
        o: String?? = nil
    ) -> OrderMetadata {
        return OrderMetadata(
            o: o ?? self.o
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - OrderShipping
struct OrderShipping: Codable {
    var amount: Int?
    var description, recipientName: [Description]?
    var address: Address?
    var provider: Invoice?

    enum CodingKeys: String, CodingKey {
        case amount, description
        case recipientName = "recipient_name"
        case address, provider
    }
}

// MARK: OrderShipping convenience initializers and mutators

extension OrderShipping {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(OrderShipping.self, from: data)
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
        amount: Int?? = nil,
        description: [Description]?? = nil,
        recipientName: [Description]?? = nil,
        address: Address?? = nil,
        provider: Invoice?? = nil
    ) -> OrderShipping {
        return OrderShipping(
            amount: amount ?? self.amount,
            description: description ?? self.description,
            recipientName: recipientName ?? self.recipientName,
            address: address ?? self.address,
            provider: provider ?? self.provider
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Tax
struct Tax: Codable {
    var name, description, type: String?
    var value: Int?
}

// MARK: Tax convenience initializers and mutators

extension Tax {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Tax.self, from: data)
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
        name: String?? = nil,
        description: String?? = nil,
        type: String?? = nil,
        value: Int?? = nil
    ) -> Tax {
        return Tax(
            name: name ?? self.name,
            description: description ?? self.description,
            type: type ?? self.type,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Receipt
struct Receipt: Codable {
    var email, sms: Bool?
}

// MARK: Receipt convenience initializers and mutators

extension Receipt {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Receipt.self, from: data)
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
        email: Bool?? = nil,
        sms: Bool?? = nil
    ) -> Receipt {
        return Receipt(
            email: email ?? self.email,
            sms: sms ?? self.sms
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Topup
struct Topup: Codable {
    var wallet: Invoice?
    var amount: Int?
    var currency: String?
    var netAmount: Bool?
    var applicationFee: ApplicationFee?
    var reference: String?

    enum CodingKeys: String, CodingKey {
        case wallet, amount, currency
        case netAmount = "net_amount"
        case applicationFee = "application_fee"
        case reference
    }
}

// MARK: Topup convenience initializers and mutators

extension Topup {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Topup.self, from: data)
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
        wallet: Invoice?? = nil,
        amount: Int?? = nil,
        currency: String?? = nil,
        netAmount: Bool?? = nil,
        applicationFee: ApplicationFee?? = nil,
        reference: String?? = nil
    ) -> Topup {
        return Topup(
            wallet: wallet ?? self.wallet,
            amount: amount ?? self.amount,
            currency: currency ?? self.currency,
            netAmount: netAmount ?? self.netAmount,
            applicationFee: applicationFee ?? self.applicationFee,
            reference: reference ?? self.reference
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Transaction
struct Transaction: Codable {
    var cardHolderLogin: CardHolderLogin?
    var metadata: TransactionMetadata?
    var reference: String?
    var paymentAgreement: PaymentAgreement?

    enum CodingKeys: String, CodingKey {
        case cardHolderLogin = "card_holder_login"
        case metadata, reference
        case paymentAgreement = "payment_agreement"
    }
}

// MARK: Transaction convenience initializers and mutators

extension Transaction {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Transaction.self, from: data)
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
        cardHolderLogin: CardHolderLogin?? = nil,
        metadata: TransactionMetadata?? = nil,
        reference: String?? = nil,
        paymentAgreement: PaymentAgreement?? = nil
    ) -> Transaction {
        return Transaction(
            cardHolderLogin: cardHolderLogin ?? self.cardHolderLogin,
            metadata: metadata ?? self.metadata,
            reference: reference ?? self.reference,
            paymentAgreement: paymentAgreement ?? self.paymentAgreement
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CardHolderLogin
struct CardHolderLogin: Codable {
    var type, timestamp: String?
}

// MARK: CardHolderLogin convenience initializers and mutators

extension CardHolderLogin {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CardHolderLogin.self, from: data)
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
        timestamp: String?? = nil
    ) -> CardHolderLogin {
        return CardHolderLogin(
            type: type ?? self.type,
            timestamp: timestamp ?? self.timestamp
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - TransactionMetadata
struct TransactionMetadata: Codable {
    var s: String?
}

// MARK: TransactionMetadata convenience initializers and mutators

extension TransactionMetadata {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TransactionMetadata.self, from: data)
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
        s: String?? = nil
    ) -> TransactionMetadata {
        return TransactionMetadata(
            s: s ?? self.s
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - PaymentAgreement
struct PaymentAgreement: Codable {
    var id: String?
    var contract: Invoice?
}

// MARK: PaymentAgreement convenience initializers and mutators

extension PaymentAgreement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PaymentAgreement.self, from: data)
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
        id: String?? = nil,
        contract: Invoice?? = nil
    ) -> PaymentAgreement {
        return PaymentAgreement(
            id: id ?? self.id,
            contract: contract ?? self.contract
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
