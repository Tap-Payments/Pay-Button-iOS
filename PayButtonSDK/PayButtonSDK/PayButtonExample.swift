//
//  CardWebSDKExample.swift
//  TapCardCheckoutExample
//
//

import UIKit
import Pay_Button_iOS
import Toast
import CryptoKit

class PayButtonExample: UIViewController {
    @IBOutlet weak var payButton: PayButtonView!
    @IBOutlet weak var eventsTextView: UITextView!
    
    @IBOutlet weak var authenticatedTokenButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    var toast:Toast?
    
    var selectedButtonType:PayButtonTypeEnum = .Knet
    
    var dictConfig:[String:Any] = [
        "debug":true,
        "operator": ["publicKey": "pk_test_Wa4ju8UC1zoi0HhST9yO3M6n", "hashString": ""],
        "scope": "charge",
        "transaction": [
          "authentication": true,
          "authenticate":[
            "id":"",
            "required":true
          ],
          "source":[
            "id":""
          ],
          "authorize": [
            "type": "VOID",
            "time": 12,
          ],
          "reference": "trx",
          "metadata": [:],
        ],
        "order": [
          "id": "",
          "amount": 100,
          "currency": "KWD",
          "description": "Authentication description",
          "reference": "ordRef",
          "metadata": [:],
        ],
        "invoice": ["id": ""],
        "merchant": ["id": ""],
        "customer": [
          "id": "",
          "name": [["lang": "en", "first": "TAP", "middle": "", "last": "PAYMENTS"]],
          "contact": [
            "email": "tap@tap.company",
            "phone": ["countryCode": "+965", "number": "88888888"],
          ],
        ],
        "fieldVisibility":["card": [
                                "cvv":true,
                                "cardHolder":true]
                          ],
        "acceptance": [
                  "supportedSchemes": ["AMERICAN_EXPRESS", "VISA", "MASTERCARD", "OMANNET", "MADA"],
                  "supportedFundSource": ["DEBIT","CREDIT"],
                  "supportedPaymentAuthentications": ["3DS"],
                ],
        "features":["alternativeCardInputs":["cardScanner":true],
                    "acceptanceBadge":true,
                    "customerCards":["saveCard":true,
                                     "autoSaveCard":true]
                   ],
        "interface": [
          "locale": "en",
          "theme": UIView().traitCollection.userInterfaceStyle == .dark ? "dark" : "light",
          "edges": "circular",
          "colorStyle": UIView().traitCollection.userInterfaceStyle == .dark
            ? "monochrome" : "colored",
          "loader": true,
          "powered":true
        ],
        "post": ["url": ""],
    ] {
        didSet {
            generateHashString()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPayButton()
           if let jsonData = try? JSONSerialization.data(withJSONObject: dictConfig, options: .prettyPrinted) {
               print(String(decoding: jsonData, as: UTF8.self))
        }
    }
    
    func generateHashString() {
        /*var hashString:String = (dictConfig as NSDictionary).value(forKeyPath: "operator.hashString") as? String ?? ""
        if hashString == "" {
            let publicKey:String = (dictConfig as NSDictionary).value(forKeyPath: "operator.publicKey") as? String ?? "pk_test_Wa4ju8UC1zoi0HhST9yO3M6n"
            let amount:Double = (dictConfig as NSDictionary).value(forKeyPath: "order.amount") as? Double ?? 1.0
            let currency:String = (dictConfig as NSDictionary).value(forKeyPath: "order.currency") as? String ?? "KWD"
            let postUrl:String = (dictConfig as NSDictionary).value(forKeyPath: "post.url") as? String ?? ""
            let transactionRef:String = (dictConfig as NSDictionary).value(forKeyPath: "transaction.reference") as? String ?? "trx"
            let secretKey:String = publicKey == "pk_test_Wa4ju8UC1zoi0HhST9yO3M6n" ? "sk_test_UvDY01mebtdIK8Sox6iJFRQ9" : "sk_live_kn49iOuAHZ0xQGPDXFhBV71N"
            hashString = PayButtonExample.generateTapHashString(publicKey: publicKey, secretKey: secretKey, amount: amount, currency: currency, postUrl: postUrl, transactionReference: transactionRef)
            self.update(dictionary: &self.dictConfig, at: ["operator","hashString"], with: hashString)
        }*/
    }

    @IBAction func refreshButtonClicked(_ sender: Any) {
        setupPayButton()
    }
    
    func setupPayButton() {
        refreshButton.isHidden = true
        generateHashString()
        payButton.initPayButton(configDict: self.dictConfig, delegate: self, payButtonType: selectedButtonType)
    }
    
    @IBAction func optionsClicked(_ sender: Any) {
        let alertController:UIAlertController = .init(title: "Options", message: "Select one please", preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Copy logs", style: .default, handler: { _ in
            UIPasteboard.general.string = self.eventsTextView.text
        }))
        
        alertController.addAction(.init(title: "Clear logs", style: .default, handler: { _ in
            self.eventsTextView.text = ""
        }))
        
        alertController.addAction(.init(title: "Configs", style: .default, handler: { _ in
            self.configClicked()
        }))
        
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    func configClicked() {
        self.update(dictionary: &self.dictConfig, at: ["operator","hashString"], with: "")
        let configCtrl:PayButtonSettingsViewController = storyboard?.instantiateViewController(withIdentifier: "BenefitPayButtonSettingsViewController") as! PayButtonSettingsViewController
        configCtrl.config = dictConfig
        configCtrl.selectedButtonType = selectedButtonType
        configCtrl.delegate = self
        //present(configCtrl, animated: true)
        self.navigationController?.pushViewController(configCtrl, animated: true)
        
    }
    
    /**
         This is a helper method showing how can you generate a hash string when performing live charges
         - Parameter publicKey:             The Tap public key for you as a merchant pk_.....
         - Parameter secretKey:             The Tap secret key for you as a merchant sk_.....
         - Parameter amount:                The amount you are passing to the SDK, ot the amount you used in the order if you created the order before.
         - Parameter currency:              The currency code you are passing to the SDK, ot the currency code you used in the order if you created the order before. PS: It is the capital case of the 3 iso country code ex: SAR, KWD.
         - Parameter post:                  The post url you are passing to the SDK, ot the post url you pass within the Charge API. If you are not using postUrl please pass it as empty string
         - Parameter transactionReference:  The reference.trasnsaction you are passing to the SDK(not all SDKs supports this,) or the reference.trasnsaction  you pass within the Charge API. If you are not using reference.trasnsaction please pass it as empty string
         */
        static func generateTapHashString(publicKey:String, secretKey:String, amount:Double, currency:String, postUrl:String = "", transactionReference:String = "") -> String {
            // Let us generate our encryption key
            let key = SymmetricKey(data: Data(secretKey.utf8))
            // For amounts, you will need to make sure they are formatted in a way to have the correct number of decimal points. For BHD we need them to have 3 decimal points
            // We will need to format it based on the currency's decimal points
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = ""
            numberFormatter.currencyCode = currency
            let formattedAmount:String = numberFormatter.string(for: amount) ?? ""
            // Let us format the string that we will hash
            let toBeHashed = "x_publickey\(publicKey)x_amount\(formattedAmount)x_currency\(currency)x_transaction\(transactionReference)x_post\(postUrl)"
            // let us generate the hash string now using the HMAC SHA256 algorithm
            let signature = HMAC<SHA256>.authenticationCode(for: Data(toBeHashed.utf8), using: key)
            let hashedString = Data(signature).map { String(format: "%02hhx", $0) }.joined()
            return hashedString
            
            
        }
    
    
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
    /*func setConfig(config: CardWebSDKConfig) {
        self.config = config
    }*/
}


extension PayButtonExample: PayButtonSettingsViewControllerDelegate {
    
    func updateConfig(config: [String:Any], selectedButtonType: PayButtonTypeEnum) {
        self.dictConfig = config
        self.selectedButtonType = selectedButtonType
        setupPayButton()
    }
}

extension PayButtonExample: PayButtonDelegate {
    
    func onError(data: String) {
        //print("CardWebSDKExample onError \(data)")
        eventsTextView.text = "\n\n========\n\nonError \(data)\(eventsTextView.text ?? "")"
        refreshButton.isHidden = false
        self.view.isUserInteractionEnabled = true
        toast?.close()
    }
    
    func onSuccess(data: String) {
        //print("CardWebSDKExample onError \(data)")
        if let json = try? JSONSerialization.jsonObject(with: Data(data.utf8), options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            let controller:OnSuccessViewController = storyboard?.instantiateViewController(withIdentifier: "OnSuccessViewController") as! OnSuccessViewController
            eventsTextView.text = "\n\n========\n\nonSuccess \(String(decoding: jsonData, as: UTF8.self))\(eventsTextView.text ?? "")"
            controller.string = String(decoding: jsonData, as: UTF8.self)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                //self.present(controller, animated: true, completion: nil)
            }
        } else {
            eventsTextView.text = "\n\n========\n\nonSuccess \(data)\(eventsTextView.text ?? "")"
        }
        refreshButton.isHidden = false
    }
    
    func onOrderCreated(data: String) {
        //print("CardWebSDKExample onError \(data)")
        eventsTextView.text = "\n\n========\n\nonOrderCreated \(data)\(eventsTextView.text ?? "")"
    }
    
    func onChargeCreated(data: String) {
        //print("CardWebSDKExample onError \(data)")
        eventsTextView.text = "\n\n========\n\nonChargeCreated \(data)\(eventsTextView.text ?? "")"
    }
    
    func onReady(){
        //print("CardWebSDKExample onReady")
        eventsTextView.text = "\n\n========\n\nonReady\(eventsTextView.text ?? "")"
        self.view.isUserInteractionEnabled = true
        toast?.close()
    }
    
    func onClick() {
        //print("CardWebSDKExample onFocus")
        eventsTextView.text = "\n\n========\n\nonClicked\(eventsTextView.text ?? "")"
    }
    
    func onCanceled() {
        eventsTextView.text = "\n\n========\n\nonCanceled\(eventsTextView.text ?? "")"
    }
    
    func onBinIdentification(data: String) {
        eventsTextView.text = "\n\n========\n\nonBinIdentification \(data)\(eventsTextView.text ?? "")"
    }
}
