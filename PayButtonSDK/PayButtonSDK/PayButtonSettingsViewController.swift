//
//  CardSettingsViewController.swift
//  TapCardCheckoutExample
//
//  Created by Osama Rabie on 07/09/2023.
//

import UIKit
import Eureka
import Pay_Button_iOS

protocol PayButtonSettingsViewControllerDelegate {
    func updateConfig()
}

class PayButtonSettingsViewController: FormViewController {

    var delegate: PayButtonSettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        form +++ Section("button")
        <<< AlertRow<String>("button.type"){ row in
            row.title = "Button"
            // Qpay shows as naps in the demo only, nothing about the sdk's own QPAY type changes.
            // The picker's value is what gets sent as the accepted payment method either way
            row.options = PayButtonTypeEnum.allCases.map{ PayButtonExample.demoLabel(for: $0.toString()) }
            row.value = PayButtonExample.demoLabel(for: PayButtonExample.selectedPaymentMethod.isEmpty ? "KNET" : PayButtonExample.selectedPaymentMethod)
            row.onChange { [weak self] row in
                // The picker's value is what actually gets sent as the accepted payment method,
                // naps included .. there is nowhere else naps needs to be translated back from
                let selectedMethod:String = row.value ?? "KNET"
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentMethods = [selectedMethod]
                // The token scopes belong to one wallet each, so the scope list follows the button
                self?.refreshScopeOptions(for: selectedMethod)
                // Deema and tamara are on merchants of their own, so the id has to go with the key
                PayButtonExample.alignMerchantWithTheKey()
                self?.refreshMerchantId()
                // Paypal only takes usd and deema only kwd, so the currency follows the button too
                PayButtonExample.alignCurrencyWithTheButton()
                self?.refreshOrderCurrency()
            }
        }
        
        /*form +++ Section("operator")
        <<< AlertRow<String>("operator.publicKey"){ row in
            row.title = "Tap public key"
            row.options = ["pk_test_6jdl4Qo0FYOSXmrZTR1U5EHp","pk_live_I8aWfZkiGtw9HYsRCcAgQzS6"]
            row.value = (config! as NSDictionary).value(forKeyPath: "operator.publicKey") as? String ?? "pk_test_HJN863LmO15EtDgo9cqK7sjS"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["operator","publicKey"], with: row.value ?? "pk_test_HJN863LmO15EtDgo9cqK7sjS")
            }
        }
        
        <<< TextRow("operator.hashString"){ row in
            row.title = "A hashstring to validate"
            row.placeholder = "Leave empty for auto generation"
            row.value = (config! as NSDictionary).value(forKeyPath: "operator.hashString") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["operator","hashString"], with: row.value ?? "")
            }
        }*/
        
        
        form +++ Section("intent")
        <<< TextRow("purpose"){ row in
            row.title = "purpose"
            row.value = PayButtonExample.intentRequestRequest.purpose ?? ""
            row.onChange { row in PayButtonExample.intentRequestRequest.purpose = row.value ?? "" }
        }
        <<< TextRow("statementDescriptor"){ row in
            row.title = "statement descriptor"
            row.value = PayButtonExample.intentRequestRequest.statementDescriptor ?? ""
            row.onChange { row in PayButtonExample.intentRequestRequest.statementDescriptor = row.value ?? "" }
        }
        <<< TextRow("description"){ row in
            row.title = "description"
            row.value = PayButtonExample.intentRequestRequest.description ?? ""
            row.onChange { row in PayButtonExample.intentRequestRequest.description = row.value ?? "" }
        }
        <<< TextRow("reference"){ row in
            row.title = "reference"
            row.value = PayButtonExample.intentRequestRequest.reference ?? ""
            row.onChange { row in PayButtonExample.intentRequestRequest.reference = row.value ?? "" }
        }
        <<< SwitchRow("customerInitiated"){ row in
            row.title = "customer initiated"
            row.value = PayButtonExample.intentRequestRequest.customerInitiated ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.customerInitiated = row.value ?? true }
        }
        <<< SwitchRow("authenticate.required"){ row in
            row.title = "authenticate required"
            row.value = PayButtonExample.intentRequestRequest.authenticate?.authenticateRequired ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.authenticate?.authenticateRequired = row.value ?? true }
        }

        form +++ Section("scope")
        <<< AlertRow<String>("scope"){ row in
            row.title = "Scope"
            row.options = PayButtonConfig.Scope.allowed(for: PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentMethods?.first).map { $0.rawValue }
            row.value = PayButtonExample.intentRequestRequest.scope ?? PayButtonConfig.Scope.charge.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.scope = row.value ?? PayButtonConfig.Scope.charge.rawValue
            }
        }
        
        form +++ Section("transaction")
        <<< TextRow("transaction.reference"){ row in
            row.title = "Trx ref"
            row.placeholder = "Enter your trx ref"
            row.value = PayButtonExample.intentRequestRequest.transaction?.reference ?? ""
            row.onChange { row in
                PayButtonExample.intentRequestRequest.transaction?.reference = row.value ?? ""
            }
        }
        
        /*<<< AlertRow<String>("transaction.authorizetype"){ row in
            row.title = "transaction.authorizetype"
            row.options = ["VOID","CAPTURE"]
            row.value = (config! as NSDictionary).value(forKeyPath: "transaction.authorize.type") as? String ?? "VOID"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["transaction","authorize","type"], with: row.value ?? "VOID")
            }
        }
        
        <<< AlertRow<Int>("transaction.authorizetime"){ row in
            row.title = "transaction.authorizetime"
            row.options = [12,24,36]
            row.value = (config! as NSDictionary).value(forKeyPath: "transaction.authorize.time") as? Int ?? 12
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["transaction","authorize","time"], with: row.value ?? 12)
            }
        }*/
        
        form +++ Section("order")
        <<< TextRow("order.id"){ row in
            row.title = "Tap order id"
            row.placeholder = "Enter your tap order id"
            row.value = PayButtonExample.intentRequestRequest.order?.id ?? ""
            row.onChange { row in
                PayButtonExample.intentRequestRequest.order?.id = row.value ?? ""
            }
        }
        <<< DecimalRow("order.amount"){ row in
            row.title = "order amount"
            row.placeholder = "Enter order's amount"
            row.value = PayButtonExample.intentRequestRequest.order?.amount ?? 1.0
            row.onChange { row in
                PayButtonExample.intentRequestRequest.order?.amount = row.value ?? 1.0
            }
        }
        <<< AlertRow<String>("order.currency"){ row in
            row.title = "order currency"
            row.options = PayButtonConfig.Currency.allRawValues
            row.value = PayButtonExample.intentRequestRequest.order?.currency?.uppercased() ?? PayButtonConfig.Currency.kwd.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.order?.currency = row.value ?? PayButtonConfig.Currency.kwd.rawValue
            }
        }
        
        /*<<< TextRow("order.description"){ row in
            row.title = "order description"
            row.placeholder = "Enter order's description"
            row.value = PayButtonExample.intentRequestRequest.order?.description ?? "KWD"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["order","description"], with: row.value ?? "")
            }
        }*/
        
        <<< TextRow("order.reference"){ row in
            row.title = "order reference"
            row.placeholder = "Enter order's reference"
            row.value = PayButtonExample.intentRequestRequest.order?.reference ?? ""
            row.onChange { row in
                PayButtonExample.intentRequestRequest.order?.reference = row.value ?? ""
            }
        }
        
        form +++ Section("merchant")
        <<< TextRow("merchant.id"){ row in
            row.title = "Tap merchant id"
            row.placeholder = "Enter your tap merchnt id"
            row.value = PayButtonExample.intentRequestRequest.merchant?.id ?? ""
            row.onChange { row in
                PayButtonExample.intentRequestRequest.merchant?.id = row.value ?? ""
            }
        }
        
        form +++ Section("customer")
       <<< TextRow("customer.id"){ row in
           row.title = "Customer id"
           row.placeholder = "Enter customer's id"
           row.value = PayButtonExample.intentRequestRequest.customer?.id ?? ""
           row.onChange { row in
               PayButtonExample.intentRequestRequest.customer?.id = row.value ?? ""
           }
       }
        
        /*<<< TextRow("customer.first"){ row in
            row.title = "First name"
            row.placeholder = "Enter customer's first name"
            row.value = (config! as NSDictionary).value(forKeyPath: "customer.name.first") as? String ?? "Tap"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["customer","name", "first"], with: row.value ?? "Tap")
            }
        }
        
        <<< TextRow("customer.middle"){ row in
            row.title = "Middle name"
            row.placeholder = "Enter customer's middle name"
            row.value = (config! as NSDictionary).value(forKeyPath: "customer.name.middle") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["customer","name", "middle"], with: row.value ?? "")
            }
        }
        
        
        <<< TextRow("customer.last"){ row in
            row.title = "Last name"
            row.placeholder = "Enter customer's last name"
            row.value = (config! as NSDictionary).value(forKeyPath: "customer.name.last") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["customer","name", "last"], with: row.value ?? "Payments")
            }
        }*/
        
        
        form +++ Section("acceptance")
        <<< MultipleSelectorRow<String>("acceptance.supportedRegions"){ row in
            row.title = "supportedRegions"
            row.options = PayButtonConfig.AcceptanceRegion.allRawValues
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedRegions ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedRegions = selected.isEmpty ? nil : selected
            }
        }

        <<< MultipleSelectorRow<String>("acceptance.supportedCurrencies"){ row in
            row.title = "supportedCurrencies"
            row.options = PayButtonConfig.Currency.allRawValues
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedCurrencies ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedCurrencies = selected.isEmpty ? nil : selected
            }
        }

        <<< MultipleSelectorRow<String>("acceptance.supportedSchemes"){ row in
            row.title = "supportedSchemes"
            row.options = PayButtonConfig.Scheme.allRawValues
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedSchemes ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedSchemes = selected.isEmpty ? nil : selected
            }
        }

        <<< MultipleSelectorRow<String>("acceptance.supportedPaymentAuthentications"){ row in
            row.title = "supportedPaymentAuthentications"
            row.options = PayButtonConfig.PaymentAuthentication.allRawValues
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentAuthentications ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentAuthentications = selected.isEmpty ? nil : selected
            }
        }

        <<< MultipleSelectorRow<String>("acceptance.supportedPaymentFlows"){ row in
            row.title = "supportedPaymentFlows"
            row.options = PayButtonConfig.PaymentFlow.allRawValues
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentFlows ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentFlows = selected.isEmpty ? nil : selected
            }
        }

        <<< MultipleSelectorRow<String>("acceptance.supportedPaymentTypes"){ row in
            row.title = "supportedPaymentTypes"
            row.options = PayButtonConfig.AcceptancePaymentType.allRawValues
            // Left unset by default, the web demo does not send this field at all
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentTypes ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedPaymentTypes = selected.isEmpty ? nil : selected
            }
        }

        <<< MultipleSelectorRow<String>("acceptance.supportedFundSource"){ row in
            row.title = "supportedFundSource"
            row.options = PayButtonConfig.FundSource.allRawValues
            row.value = Set(PayButtonExample.intentRequestRequest.config?.acceptance?.supportedFundSource ?? [])
            row.onChange { row in
                let selected:[String] = Array(row.value ?? [])
                PayButtonExample.intentRequestRequest.config?.acceptance?.supportedFundSource = selected.isEmpty ? nil : selected
            }
        }
        
        /*<<< MultipleSelectorRow<String>("acceptance.supportedPaymentAuthentications"){ row in
            row.title = "supportedPaymentAuthentications"
            row.options = ["3DS"]
            row.value = Set((config! as NSDictionary).value(forKeyPath: "acceptance.supportedPaymentAuthentications") as? [String] ?? ["3DS"])
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["acceptance","supportedPaymentAuthentications"], with: Array(row.value ?? ["3DS"]))
            }
        }*/
        
        form +++ Section("features")
        <<< SwitchRow("features.acceptanceBadge"){ row in
            row.title = "acceptance badge"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.acceptanceBadge ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.acceptanceBadge = row.value ?? true }
        }
        <<< SwitchRow("features.order"){ row in
            row.title = "order"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.order ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.order = row.value ?? true }
        }
        <<< SwitchRow("features.multipleCurrencies"){ row in
            row.title = "multiple currencies"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.multipleCurrencies ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.multipleCurrencies = row.value ?? true }
        }
        <<< SwitchRow("features.customerCards.saveCard"){ row in
            row.title = "save card"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.customerCards?.saveCard ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.customerCards?.saveCard = row.value ?? true }
        }
        <<< SwitchRow("features.customerCards.autoSaveCard"){ row in
            row.title = "auto save card"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.customerCards?.autoSaveCard ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.customerCards?.autoSaveCard = row.value ?? true }
        }
        <<< SwitchRow("features.customerCards.displaySavedCards"){ row in
            row.title = "display saved cards"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.customerCards?.displaySavedCards ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.customerCards?.displaySavedCards = row.value ?? true }
        }
        <<< SwitchRow("features.alternativeCardInputs.cardScanner"){ row in
            row.title = "card scanner"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.alternativeCardInputs?.cardScanner ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.alternativeCardInputs?.cardScanner = row.value ?? true }
        }
        <<< SwitchRow("features.alternativeCardInputs.cardNFC"){ row in
            row.title = "card nfc"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.alternativeCardInputs?.cardNFC ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.alternativeCardInputs?.cardNFC = row.value ?? true }
        }
        <<< MultipleSelectorRow<String>("features.shippingContactFields"){ row in
            row.title = "shipping contact fields"
            row.options = ["postalAddress", "name", "email", "phone", "phoneticName"]
            row.value = Set(PayButtonExample.intentRequestRequest.config?.features?.shippingContactFields ?? ["postalAddress", "name", "email"])
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.shippingContactFields = Array(row.value ?? ["postalAddress", "name", "email"]) }
        }
        <<< SwitchRow("features.supportsCouponCode"){ row in
            row.title = "supports coupon code"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.supportsCouponCode ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.supportsCouponCode = row.value ?? true }
        }
        <<< TextRow("features.couponCode"){ row in
            row.title = "coupon code"
            row.placeholder = "Leave empty for none"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.couponCode ?? ""
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.features?.couponCode = row.value ?? "" }
        }
        <<< TextRow("features.shippingMethods.standard.amount"){ row in
            row.title = "standard shipping amount"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.shippingMethods?.first(where: { $0.identifier == "standard" })?.amount ?? "0.00"
            row.onChange { row in
                let methods = PayButtonExample.intentRequestRequest.config?.features?.shippingMethods ?? []
                PayButtonExample.intentRequestRequest.config?.features?.shippingMethods = methods.map { method in
                    guard method.identifier == "standard" else { return method }
                    return method.with(amount: row.value ?? "0.00")
                }
            }
        }
        <<< TextRow("features.shippingMethods.express.amount"){ row in
            row.title = "express shipping amount"
            row.value = PayButtonExample.intentRequestRequest.config?.features?.shippingMethods?.first(where: { $0.identifier == "express" })?.amount ?? "5.00"
            row.onChange { row in
                let methods = PayButtonExample.intentRequestRequest.config?.features?.shippingMethods ?? []
                PayButtonExample.intentRequestRequest.config?.features?.shippingMethods = methods.map { method in
                    guard method.identifier == "express" else { return method }
                    return method.with(amount: row.value ?? "5.00")
                }
            }
        }

        form +++ Section("field visibility")
        <<< SwitchRow("fieldVisibility.name"){ row in
            row.title = "name"
            row.value = PayButtonExample.intentRequestRequest.config?.fieldVisibility?.name ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.fieldVisibility?.name = row.value ?? true }
        }
        <<< SwitchRow("fieldVisibility.card.cardholder"){ row in
            row.title = "card holder"
            row.value = PayButtonExample.intentRequestRequest.config?.fieldVisibility?.card?.cardholder ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.fieldVisibility?.card?.cardholder = row.value ?? true }
        }
        <<< SwitchRow("fieldVisibility.contact.email"){ row in
            row.title = "contact email"
            row.value = PayButtonExample.intentRequestRequest.config?.fieldVisibility?.contact?.email ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.fieldVisibility?.contact?.email = row.value ?? true }
        }
        <<< SwitchRow("fieldVisibility.contact.number"){ row in
            row.title = "contact number"
            row.value = PayButtonExample.intentRequestRequest.config?.fieldVisibility?.contact?.number ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.fieldVisibility?.contact?.number = row.value ?? true }
        }
        <<< SwitchRow("fieldVisibility.shipping.address"){ row in
            row.title = "shipping address"
            row.value = PayButtonExample.intentRequestRequest.config?.fieldVisibility?.shipping?.address ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.config?.fieldVisibility?.shipping?.address = row.value ?? true }
        }

        form +++ Section("receipt & checkout")
        <<< SwitchRow("receipt.email"){ row in
            row.title = "receipt email"
            row.value = PayButtonExample.intentRequestRequest.receipt?.email ?? false
            row.onChange { row in PayButtonExample.intentRequestRequest.receipt?.email = row.value ?? false }
        }
        <<< SwitchRow("receipt.sms"){ row in
            row.title = "receipt sms"
            row.value = PayButtonExample.intentRequestRequest.receipt?.sms ?? false
            row.onChange { row in PayButtonExample.intentRequestRequest.receipt?.sms = row.value ?? false }
        }
        <<< SwitchRow("checkout.auto"){ row in
            row.title = "checkout auto"
            row.value = PayButtonExample.intentRequestRequest.checkout?.auto ?? true
            row.onChange { row in PayButtonExample.intentRequestRequest.checkout?.auto = row.value ?? true }
        }

        form +++ Section("interface")
        <<< AlertRow<String>("interface.locale"){ row in
            row.title = "locale"
            row.options = PayButtonConfig.Locale.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.locale ?? PayButtonConfig.Locale.en.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.locale = row.value ?? PayButtonConfig.Locale.en.rawValue
            }
        }

        <<< AlertRow<String>("interface.direction"){ row in
            row.title = "direction"
            row.options = PayButtonConfig.Direction.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.direction ?? PayButtonConfig.Direction.dynamic.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.direction = row.value ?? PayButtonConfig.Direction.dynamic.rawValue
            }
        }

        <<< AlertRow<String>("interface.cardDirection"){ row in
            row.title = "card direction"
            row.options = PayButtonConfig.Direction.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.cardDirection ?? PayButtonConfig.Direction.ltr.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.cardDirection = row.value ?? PayButtonConfig.Direction.ltr.rawValue
            }
        }

        <<< AlertRow<String>("interface.theme"){ row in
            row.title = "theme"
            row.options = PayButtonConfig.ThemeMode.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.theme ?? PayButtonConfig.ThemeMode.light.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.theme = row.value ?? PayButtonConfig.ThemeMode.light.rawValue
            }
        }

        <<< AlertRow<String>("interface.edges"){ row in
            row.title = "edges"
            row.options = PayButtonConfig.Edges.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.edges ?? PayButtonConfig.Edges.curved.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.edges = row.value ?? PayButtonConfig.Edges.curved.rawValue
            }
        }

        <<< AlertRow<String>("interface.colorStyle"){ row in
            row.title = "colorStyle"
            row.options = PayButtonConfig.ColorStyle.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.colorStyle ?? PayButtonConfig.ColorStyle.colored.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.colorStyle = row.value ?? PayButtonConfig.ColorStyle.colored.rawValue
            }
        }

        <<< AlertRow<String>("interface.userExperience"){ row in
            row.title = "user experience"
            row.options = PayButtonConfig.UserExperience.allRawValues
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.userExperience ?? PayButtonConfig.UserExperience.popup.rawValue
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.userExperience = row.value ?? PayButtonConfig.UserExperience.popup.rawValue
            }
        }

        <<< SwitchRow("interface.loader"){ row in
            row.title = "loader"
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.loader ?? true
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.loader = row.value ?? true
            }
        }

        <<< SwitchRow("interface.powered"){ row in
            row.title = "powered by tap"
            row.value = PayButtonExample.intentRequestRequest.config?.interface?.powered ?? true
            row.onChange { row in
                PayButtonExample.intentRequestRequest.config?.interface?.powered = row.value ?? true
            }
        }
        
        /*<<< SwitchRow("interface.loader"){ row in
                    row.title = "loader"
                    row.value = (config! as NSDictionary).value(forKeyPath: "interface.loader") as? Bool ?? true
                    row.onChange { row in
                        self.update(dictionary: &self.config!, at: ["interface","loader"], with: row.value ?? true)
                    }
                }*/
        
        
        
        
        
        /*
       
        <<< EmailRow("customer.email"){ row in
            row.title = "Contact email"
            row.placeholder = "Enter customer's email"
            row.value = config?.customer?.contact?.email ?? "tap@tap.company"
            row.onChange { row in
                self.config?.customer?.contact?.email = row.value ?? "tap@tap.company"
            }
        }
        <<< PhoneRow("customer.countryCode"){ row in
            row.title = "Contact country code"
            row.value = config?.customer?.contact?.phone?.countryCode ?? "+965"
            row.onChange { row in
                self.config?.customer?.contact?.phone?.countryCode = row.value ?? "+965"
            }
        }
        <<< PhoneRow("customer.number"){ row in
            row.title = "Contact number"
            row.value = config?.customer?.contact?.phone?.number ?? "88888888"
            row.onChange { row in
                self.config?.customer?.contact?.phone?.number = row.value ?? "88888888"
            }
        }
        
        
        
        */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateConfig()
    }

    /// Puts the order amount row back in step with the configuration, for when picking a button
    /// changed it
    private func refreshOrderAmount() {
        guard let amountRow = form.rowBy(tag: "order.amount") as? DecimalRow else { return }
        amountRow.value = PayButtonExample.intentRequestRequest.order?.amount
        amountRow.updateCell()
        amountRow.reload()
    }

    /// Puts the order currency row back in step with the configuration, for when picking a button
    /// changed it
    private func refreshOrderCurrency() {
        guard let currencyRow = form.rowBy(tag: "order.currency") as? AlertRow<String> else { return }
        currencyRow.value = PayButtonExample.intentRequestRequest.order?.currency?.uppercased()
        currencyRow.updateCell()
        currencyRow.reload()
    }

    /// Puts the merchant id row back in step with the configuration, for when picking a button
    /// emptied it
    private func refreshMerchantId() {
        guard let merchantRow = form.rowBy(tag: "merchant.id") as? TextRow else { return }
        merchantRow.value = PayButtonExample.intentRequestRequest.merchant?.id ?? ""
        merchantRow.updateCell()
        merchantRow.reload()
    }

    /// Narrows the scope picker to what the selected button can actually mint.
    /// A token scope belongs to one wallet, so switching away from Apple Pay has to drop
    /// APPLE_PAY_TOKEN, otherwise we would post a scope the backend rejects.
    /// - Parameter paymentMethod: The currently selected payment method
    private func refreshScopeOptions(for paymentMethod: String) {
        guard let scopeRow = form.rowBy(tag: "scope") as? AlertRow<String> else { return }
        let allowed:[String] = PayButtonConfig.Scope.allowed(for: paymentMethod).map { $0.rawValue }
        scopeRow.options = allowed
        // Fall back to CHARGE when the scope that was picked is no longer on offer
        if let selected = scopeRow.value, !allowed.contains(selected) {
            scopeRow.value = PayButtonConfig.Scope.charge.rawValue
            PayButtonExample.intentRequestRequest.scope = scopeRow.value
        }
        scopeRow.updateCell()
        scopeRow.reload()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func update(dictionary dict: inout [String: Any], at keys: [String], with value: Any) {

        if keys.count < 2 {
            for key in keys { dict[key] = value }
            return
        }

        var levels: [[AnyHashable: Any]] = []

        for key in keys.dropLast() {
            if let lastLevel = levels.last {
                if let currentLevel = lastLevel[key] as? [AnyHashable: Any] {
                    levels.append(currentLevel)
                }
                else if lastLevel[key] != nil, levels.count + 1 != keys.count {
                    break
                } else { return }
            } else {
                if let firstLevel = dict[keys[0]] as? [AnyHashable : Any] {
                    levels.append(firstLevel )
                }
                else { return }
            }
        }

        if levels[levels.indices.last!][keys.last!] != nil {
            levels[levels.indices.last!][keys.last!] = value
        } else { return }

        for index in levels.indices.dropLast().reversed() {
            levels[index][keys[index + 1]] = levels[index + 1]
        }

        dict[keys[0]] = levels[0]
    }

}

