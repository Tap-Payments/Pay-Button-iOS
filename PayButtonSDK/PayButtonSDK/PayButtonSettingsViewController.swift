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
    func updateConfig(config: [String:Any], selectedButtonType:PayButtonTypeEnum)
}

class PayButtonSettingsViewController: FormViewController {

    var config: [String:Any]?
    var delegate: PayButtonSettingsViewControllerDelegate?
    var selectedButtonType:PayButtonTypeEnum = .BenefitPay
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        form +++ Section("button")
        <<< AlertRow<String>("button.type"){ row in
            row.title = "Button"
            row.options = PayButtonTypeEnum.allCases.map{ $0.toString() }
            row.value = selectedButtonType.toString()
            row.onChange { row in
                self.selectedButtonType = PayButtonTypeEnum.init(rawValue: PayButtonTypeEnum.allCases.map{ $0.toString() }.firstIndex(of: row.value ?? "BENEFITPAY") ?? 0) ?? self.selectedButtonType
            }
        }
        
        form +++ Section("operator")
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
        }
        
        
        form +++ Section("scope")
        <<< AlertRow<String>("scope"){ row in
            row.title = "Scope"
            row.options = ["charge","authorize","taptoken","googlepaytoken"]
            row.value = (config! as NSDictionary).value(forKeyPath: "scope") as? String ?? "charge"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["scope"], with: row.value ?? "charge")
            }
        }
        
        form +++ Section("transaction")
        <<< TextRow("transaction.reference"){ row in
            row.title = "Trx ref"
            row.placeholder = "Enter your trx ref"
            row.value = (config! as NSDictionary).value(forKeyPath: "transaction.reference") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["transaction","reference"], with: row.value ?? "")
            }
        }
        
        <<< AlertRow<String>("transaction.authorizetype"){ row in
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
        }
        
        form +++ Section("order")
        <<< TextRow("order.id"){ row in
            row.title = "Tap order id"
            row.placeholder = "Enter your tap order id"
            row.value = (config! as NSDictionary).value(forKeyPath: "order.id") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["order","id"], with: row.value ?? "")
            }
        }
        <<< DecimalRow("order.amount"){ row in
            row.title = "order amount"
            row.placeholder = "Enter order's amount"
            row.value = (config?["order"] as? [String:Any])?["amount"] as? Double ?? 1.0
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["order","amount"], with: row.value ?? 1.0)
            }
        }
        <<< TextRow("order.currency"){ row in
            row.title = "order currency"
            row.placeholder = "Enter order's currency"
            
            row.value = (config! as NSDictionary).value(forKeyPath: "order.currency") as? String ?? "SAR"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["order","currency"], with: row.value ?? "SAR")
            }
        }
        
        <<< TextRow("order.description"){ row in
            row.title = "order description"
            row.placeholder = "Enter order's description"
            
            row.value = (config! as NSDictionary).value(forKeyPath: "order.description") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["order","description"], with: row.value ?? "")
            }
        }
        
        <<< TextRow("order.reference"){ row in
            row.title = "order reference"
            row.placeholder = "Enter order's reference"
            
            row.value = (config! as NSDictionary).value(forKeyPath: "order.reference") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["order","reference"], with: row.value ?? "")
            }
        }
        
        form +++ Section("merchant")
        <<< TextRow("merchant.id"){ row in
            row.title = "Tap merchant id"
            row.placeholder = "Enter your tap merchnt id"
            row.value = (config! as NSDictionary).value(forKeyPath: "merchant.id") as? String ?? ""
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["merchant","id"], with: row.value ?? "")
            }
        }
        form +++ Section("customer")
       
       <<< TextRow("customer.id"){ row in
           row.title = "Customer id"
           row.placeholder = "Enter customer's id"
           row.value = (config! as NSDictionary).value(forKeyPath: "customer.id") as? String ?? ""
           row.onChange { row in
               self.update(dictionary: &self.config!, at: ["customer","id"], with: row.value ?? "")
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
        <<< MultipleSelectorRow<String>("acceptance.supportedSchemes"){ row in
            row.title = "supportedSchemes"
            row.options = ["AMERICAN_EXPRESS","MADA","MASTERCARD","VISA","OMANNET","MEEZA"]
            row.value = Set((config! as NSDictionary).value(forKeyPath: "acceptance.supportedSchemes") as? [String] ?? ["AMERICAN_EXPRESS","MADA","MASTERCARD","VISA","OMANNET","MEEZA"])
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["acceptance","supportedSchemes"], with: Array(row.value ?? ["AMERICAN_EXPRESS","MADA","MASTERCARD","VISA","OMANNET","MEEZA"]))
            }
        }
        
        <<< MultipleSelectorRow<String>("acceptance.supportedFundSource"){ row in
            row.title = "supportedFundSource"
            row.options = ["CREDIT","DEBIT"]
            row.value = Set((config! as NSDictionary).value(forKeyPath: "acceptance.supportedFundSource") as? [String] ?? ["DEBIT","CREDIT"])
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["acceptance","supportedFundSource"], with: Array(row.value ?? ["DEBIT","CREDIT"]))
            }
        }
        
        <<< MultipleSelectorRow<String>("acceptance.supportedPaymentAuthentications"){ row in
            row.title = "supportedPaymentAuthentications"
            row.options = ["3DS"]
            row.value = Set((config! as NSDictionary).value(forKeyPath: "acceptance.supportedPaymentAuthentications") as? [String] ?? ["3DS"])
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["acceptance","supportedPaymentAuthentications"], with: Array(row.value ?? ["3DS"]))
            }
        }
        
        form +++ Section("interface")
        <<< AlertRow<String>("interface.locale"){ row in
            row.title = "locale"
            row.options = ["en","ar"]
            row.value = (config! as NSDictionary).value(forKeyPath: "interface.locale") as? String ?? "en"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["interface","locale"], with: row.value ?? "en")
            }
        }
        <<< AlertRow<String>("interface.theme"){ row in
            row.title = "theme"
            row.options = ["light","dark"]
            row.value = (config! as NSDictionary).value(forKeyPath: "interface.theme") as? String ?? "light"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["interface","theme"], with: row.value ?? "light")
            }
        }
        
        <<< AlertRow<String>("interface.edges"){ row in
            row.title = "edges"
            row.options = ["curved","flat"]
            row.value = (config! as NSDictionary).value(forKeyPath: "interface.edges") as? String ?? "curved"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["interface","edges"], with: row.value ?? "curved")
            }
        }
        
        <<< AlertRow<String>("interface.colorStyle"){ row in
            row.title = "colorStyle"
            row.options = ["colored","monochrome"]
            row.value = (config! as NSDictionary).value(forKeyPath: "interface.colorStyle") as? String ?? "colored"
            row.onChange { row in
                self.update(dictionary: &self.config!, at: ["interface","colorStyle"], with: row.value ?? "colored")
            }
        }
        
        <<< SwitchRow("interface.loader"){ row in
                    row.title = "loader"
                    row.value = (config! as NSDictionary).value(forKeyPath: "interface.loader") as? Bool ?? true
                    row.onChange { row in
                        self.update(dictionary: &self.config!, at: ["interface","loader"], with: row.value ?? true)
                    }
                }
        
        
        
        
        
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
        delegate?.updateConfig(config: config!, selectedButtonType: selectedButtonType)
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

