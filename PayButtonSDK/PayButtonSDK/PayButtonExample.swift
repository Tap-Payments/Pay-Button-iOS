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
    
    static var intentRequestRequest:IntentRequest = try! .init("""
{"scope":"CHARGE","purpose":"charge","statement_descriptor":"statement_descriptor","reference":"uuid_testabcdfgkgdgd121992","customer_initiated":false,"hash_string":"hash","idempotent":"","merchant":{"id":"599424","terminal":{"id":"","terminal_device":{"id":""}},"operator":{"id":"","device":{"id":""}},"payment_provider":{"technology":{"id":""},"institution":{"id":""}},"development_house":{"id":""},"platform":{"id":""}},"authenticate":{"id":"","required":true},"transaction":{"card_holder_login":{"type":"GUEST","timestamp":"123213213"},"metadata":{"s":"s"},"reference":"kjhjkhk","payment_agreement":{"id":"","contract":{"id":""}}},"invoice":{"id":""},"order":{"amount":3,"currency":"KWD","description":[{"text":"name","lang":"en"}],"reference":"","items":{"count":1,"list":[{"id":"","quantity":1,"pickup":false,"product":{"id":"","amount":2,"name":[{"text":"Laptop","lang":"en"}],"description":[{"text":"سجادة","lang":"ar"}],"category":"PHYSICAL_GOODS","metadata":{"":""},"reference":{"sku":"stock keeping unit","gtin":"global trade item number","code":"00dfd","financial_code":"0022343"}}}]},"tax":[{"name":"VAT","description":"test","type":"F","value":1}],"discount":{"type":"F","value":1},"shipping":{"amount":1,"description":[{"text":"description","lang":"en"}],"recipient_name":[{"text":"Name","lang":"en"}],"address":{"type":"home","line1":"sdfghjk","line2":"oiuytr","line3":"line3","line4":"line4","apartment":"","building":"","street":"","avenue":"","block":"","area":"","city":"salmyia","state":"kuwait","country":"kw","zip_code":"30003","postal_code":"30003"},"provider":{"id":"prov_FFSFAGGAHAAJAJ"}},"metadata":{"o":"s"}},"customer":{"id":"","name":[{"first":"OSAMA","last":"Ahmed","middle":"","title":"MR"}],"name_on_card":{"content":"OSAMA AHMED","editable":true},"contact":{"email":"f.mehmood@tap.company","phone":{"country_code":"965","number":"51234567"}},"address":{"type":"home","line1":"sdfghjk","line2":"oiuytr","line3":"line3","line4":"line4","apartment":"","building":"","street":"","avenue":"","block":"","area":"","city":"salmyia","state":"kuwait","country":"kw","zip_code":"30003","postal_code":""}},"receipt":{"email":false,"sms":false},"config":{"initiator":"MERCHANT","type":"button","features":{"acceptance_badge":true,"order":true,"multiple_currencies":true,"currency_conversions":{"dynamic":true,"location":true,"payment":true,"cobadge":true},"payments":{"card":true,"device":true,"wallet":true,"bnpl":true,"mobile":true,"cash":true,"redirect":true},"alternative_card_inputs":{"card_scanner":true,"card_nfc":true},"customer_cards":{"save_card":true,"auto_save_card":true,"display_saved_cards":true}},"acceptance":{"supported_regions":["LOCAL","REGIONAL","GLOBAL"],"supported_countries":["AE","SA","KW","EG"],"supported_currencies":["KWD","SAR","AED","OMR","QAR","BHD","EGP","GBP","USD","EUR","AED"],"supported_payment_types":["DEVICE","WEB"],"supported_payment_methods":["KNET"],"supported_schemes":["MADA","OMANNET","VISA","MASTERCARD","AMEX","BENEFIT_CARD"],"supported_fund_source":["DEBIT","CREDIT"],"supported_payment_authentications":["3DS","EMV","PASSKEY"],"supported_payment_flows":["POPUP","PAGE"]},"field_visibility":{"name":true,"card":{"number":true,"expiry":true,"cvv":true,"cardholder":true},"contact":{"email":true,"number":true},"shipping":{"address":true}},"interface":{"user_experience":"POPUP","locale":"EN","direction":"DYNAMIC","card_direction":"CIRCULAR","edges":"CIRCULAR","theme":"LIGHT","color_style":"COLOURED","loader":true,"powered":true}},"domain":{"url":"demo.tap.PayButtonSDK"},"redirect":{"url":"osama.cm"},"post":{"url":"osama.cm"},"checkout":{"auto":true,"metadata":{"udf1":"test 1","udf2":"test 2"}}}
""")

    static var examplePublicKey:String = "pk_test_6jdl4Qo0FYOSXmrZTR1U5EHp"
    static var exampleIntentId:String = "intent_rzgd5725539UhQ713R0a867"
    
    @IBOutlet weak var payButton: PayButtonView!
    @IBOutlet weak var eventsTextView: UITextView!
    
    @IBOutlet weak var refreshButton: UIButton!
        
    var dictConfig:[String:Any]  {
        return ["operator": ["publicKey": PayButtonExample.examplePublicKey],
        "intent":["id":PayButtonExample.exampleIntentId]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPayButton()
    }

    @IBAction func refreshButtonClicked(_ sender: Any) {
        setupPayButton()
    }
    
    func setupPayButton() {
        refreshButton.isHidden = false
        createIntent()
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
        let configCtrl:PayButtonSettingsViewController = storyboard?.instantiateViewController(withIdentifier: "BenefitPayButtonSettingsViewController") as! PayButtonSettingsViewController
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
    
    /*func setConfig(config: CardWebSDKConfig) {
        self.config = config
    }*/
}


extension PayButtonExample: PayButtonSettingsViewControllerDelegate {
    
    func updateConfig() {
        setupPayButton()
    }
}

extension PayButtonExample: PayButtonDelegate {
    
    func onError(data: String) {
        //print("CardWebSDKExample onError \(data)")
        eventsTextView.text = "\n\n========\n\nonError \(data)\(eventsTextView.text ?? "")"
        refreshButton.isHidden = false
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
    }
    
    func onClicked() {
        //print("CardWebSDKExample onFocus")
        eventsTextView.text = "\n\n========\n\nonClicked\(eventsTextView.text ?? "")"
    }
    
    func onCanceled() {
        eventsTextView.text = "\n\n========\n\nonCanceled\(eventsTextView.text ?? "")"
    }
    
    func createIntent() {
        eventsTextView.text = "\n\n========\n\nCreating an intent..."
        let postData = try! PayButtonExample.intentRequestRequest.jsonData()

        var request = URLRequest(url: URL(string: "https://api.tap.company/v2/intent")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer sk_test_NSln5js3fIeq0QU1MuKRXAkD", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
              guard let data = data,
                    let intentResponse:[String:Any] = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any] else {
                  self.eventsTextView.text += "\n\n========\n\nIntent creation failed:\n\(String(describing: error))..."
                return
              }
              //print(String(data: data, encoding: .utf8)!)
                guard let intentID:String = intentResponse["id"] as? String,
                      !intentID.isEmpty else{
                    self.eventsTextView.text += "\n\n========\n\nIntent creation failed:\n\(String(data: data, encoding: .utf8)!)..."
                    return
                }
                self.eventsTextView.text += "\n\n========\n\nIntent created with id: \n\(intentID)"
                PayButtonExample.exampleIntentId = intentID
                self.payButton.initPayButton(configDict: self.dictConfig, delegate: self)
            }
        }
        task.resume()
    }
}
