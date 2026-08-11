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
{
  "scope": "CHARGE",
  "purpose": "charge",
  "statement_descriptor": "statement_descriptor",
  "description": "sd",
  "reference": "uuid_testabcdfgkgdgd121992",
  "customer_initiated": true,
  "idempotent": "",
  "merchant": {
    "id": "",
    "terminal": {
      "id": "",
      "terminal_device": {
        "id": ""
      }
    },
    "operator": {
      "id": "",
      "device": {
        "id": ""
      }
    },
    "payment_provider": {
      "technology": {
        "id": ""
      },
      "institution": {
        "id": ""
      }
    },
    "development_house": {
      "id": ""
    },
    "platform": {
      "id": ""
    }
  },
  "authenticate": {
    "id": "",
    "required": true
  },
  "transaction": {
    "card_holder_login": {
      "type": "GUEST",
      "timestamp": "123213213"
    },
    "metadata": {
      "s": "s"
    },
    "reference": "kjhjkhk",
    "payment_agreement": {
      "id": "",
      "contract": {
        "id": ""
      }
    }
  },
  "invoice": {
    "id": ""
  },
  "order": {
    "amount": 3,
    "currency": "SAR",
    "description": [
      {
        "text": "name",
        "lang": "en"
      }
    ],
    "reference": "",
    "items": {
      "count": 1,
      "list": [
        {
          "id": "",
          "quantity": 1,
          "pickup": false,
          "product": {
            "id": "",
            "amount": 2,
            "name": [
              {
                "text": "Laptop",
                "lang": "en"
              }
            ],
            "description": [
              {
                "text": "سجادة",
                "lang": "ar"
              }
            ],
            "category": "PHYSICAL_GOODS",
            "metadata": {
              "": ""
            },
            "reference": {
              "sku": "stock keeping unit",
              "gtin": "global trade item number",
              "code": "00dfd",
              "financial_code": "0022343"
            }
          }
        }
      ]
    },
    "tax": [
      {
        "name": "VAT",
        "description": "test",
        "type": "F",
        "value": 1
      }
    ],
    "discount": {
      "type": "F",
      "value": 1
    },
    "shipping": {
      "amount": 1,
      "description": [
        {
          "text": "description",
          "lang": "en"
        }
      ],
      "recipient_name": [
        {
          "text": "Name",
          "lang": "en"
        }
      ],
      "address": {
        "type": "home",
        "line1": "sdfghjk",
        "line2": "oiuytr",
        "line3": "line3",
        "line4": "line4",
        "apartment": "",
        "building": "",
        "street": "",
        "avenue": "",
        "block": "",
        "area": "",
        "city": "salmyia",
        "state": "kuwait",
        "country": "kw",
        "zip_code": "30003",
        "postal_code": "30003"
      },
      "provider": {
        "id": "prov_FFSFAGGAHAAJAJ"
      }
    },
    "metadata": {
      "o": "s"
    }
  },
  "customer": {
    "id": "",
    "name": [
      {
        "first": "OSAMA",
        "last": "Ahmed",
        "middle": "",
        "title": "MR"
      }
    ],
    "name_on_card": {
      "content": "OSAMA AHMED",
      "editable": true
    },
    "contact": {
      "email": "f.mehmood@tap.company",
      "phone": {
        "country_code": "965",
        "number": "51234567"
      }
    },
    "address": {
      "type": "home",
      "line1": "sdfghjk",
      "line2": "oiuytr",
      "line3": "line3",
      "line4": "line4",
      "apartment": "",
      "building": "",
      "street": "",
      "avenue": "",
      "block": "",
      "area": "",
      "city": "salmyia",
      "state": "kuwait",
      "country": "kw",
      "zip_code": "30003",
      "postal_code": ""
    }
  },
  "receipt": {
    "email": false,
    "sms": false
  },
  "config": {
    "initiator": "CHECKOUT",
    "type": "BUTTON",
    "features": {
      "acceptance_badge": true,
      "order": true,
      "multiple_currencies": true,
      "currency_conversions": {
        "dynamic": true,
        "location": true,
        "payment": true,
        "cobadge": true
      },
      "payments": {
        "card": true,
        "device": true,
        "wallet": true,
        "bnpl": true,
        "mobile": true,
        "cash": true,
        "redirect": true
      },
      "alternative_card_inputs": {
        "card_scanner": true,
        "card_nfc": true
      },
      "customer_cards": {
        "save_card": true,
        "auto_save_card": true,
        "display_saved_cards": true
      }
    },
    "acceptance": {
      "supported_regions": [
        "LOCAL",
        "REGIONAL",
        "GLOBAL"
      ],
      "supported_currencies": [
        "KWD",
        "SAR",
        "AED",
        "OMR",
        "QAR",
        "BHD",
        "EGP",
        "GBP",
        "USD",
        "EUR",
        "AED"
      ],
      "supported_payment_methods": [
        "CARD"
      ],
      "supported_schemes": [
        "MADA",
        "OMANNET",
        "VISA",
        "MASTERCARD",
        "AMEX",
        "BENEFIT_CARD"
      ],
      "supported_fund_source": [
        "DEBIT",
        "CREDIT"
      ],
      "supported_payment_authentications": [
        "3DS",
        "EMV",
        "PASSKEY"
      ],
      "supported_payment_flows": [
        "POPUP",
        "PAGE"
      ]
    },
    "field_visibility": {
      "name": true,
      "card": {
        "number": true,
        "expiry": true,
        "cvv": true,
        "cardholder": true
      },
      "contact": {
        "email": true,
        "number": true
      },
      "shipping": {
        "address": true
      }
    },
    "interface": {
      "user_experience": "popup",
      "locale": "en",
      "direction": "dynamic",
      "card_direction": "ltr",
      "edges": "circular",
      "theme": "light",
      "color_style": "colored",
      "loader": true,
      "powered": true
    }
  },
  "domain": {
    "url": "https://demo.dev.tap.company"
  },
  "redirect": {
    "url": "demo.com"
  },
  "post": {
    "url": "demo.com"
  },
  "checkout": {
    "auto": true,
    "metadata": {
      "udf1": "test 1",
      "udf2": "test 2"
    }
  }
}
""")

    static var examplePublicKey:String = "pk_test_Vlk842B1EA7tDN5QbrfGjYzh"
    static var exampleIntentId:String = "intent_rzgd5725539UhQ713R0a869"
    
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

        alertController.addAction(.init(title: "Edit intent JSON", style: .default, handler: { _ in
            self.editIntentJSONClicked()
        }))
        
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    /// Opens the raw intent json, the mobile counterpart of the web demo's config object editor
    func editIntentJSONClicked() {
        let editor:IntentJSONEditorViewController = .init()
        editor.onSaved = { [weak self] in
            self?.setupPayButton()
        }
        // Pushed rather than presented. Presenting from the action sheet's handler races with
        // the sheet dismissing itself and the presentation gets swallowed
        navigationController?.pushViewController(editor, animated: true)
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

    func onHeightChange(height: Double) {
        // The storyboard pins the button to a fixed height, which the sdk can not override on our behalf.
        // Card based buttons (click to pay) render a form that grows, so follow the height they report.
        payButton.constraints.first { $0.firstAttribute == .height }?.constant = CGFloat(height)
        // Same curve and duration the sdk uses on its own constraint, so the two move as one
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction]) {
            self.view.layoutIfNeeded()
        }
        eventsTextView.text = "\n\n========\n\nonHeightChange \(height)\(eventsTextView.text ?? "")"
    }

    func onBinIdentification(data: String) {
        eventsTextView.text = "\n\n========\n\nonBinIdentification \(data)\(eventsTextView.text ?? "")"
    }

    func onScannerClick() {
        eventsTextView.text = "\n\n========\n\nonScannerClick\(eventsTextView.text ?? "")"
    }

    func onNfcClick() {
        eventsTextView.text = "\n\n========\n\nonNfcClick\(eventsTextView.text ?? "")"
    }

    func onThreeDSRedirect(data: String) {
        eventsTextView.text = "\n\n========\n\nonThreeDSRedirect \(data)\(eventsTextView.text ?? "")"
    }
    
    func createIntent() {
        eventsTextView.text = "\n\n========\n\nCreating an intent..."
        // The sdk takes the intent configuration as a dictionary, the same way the web sdk passes the intent object
        guard let postData:Data = try? PayButtonExample.intentRequestRequest.jsonData(),
              let intentConfig:[String:Any] = try? JSONSerialization.jsonObject(with: postData, options: .fragmentsAllowed) as? [String:Any] else {
            eventsTextView.text += "\n\n========\n\nIntent creation failed:\nCould not encode the intent configuration..."
            return
        }

        // The sdk creates the intent against the checkout mw using the public key, so no secret key is embedded in the app
        PayButtonIntent.create(config: intentConfig, publicKey: PayButtonExample.examplePublicKey) { intentResponse, error in
            if let error = error {
                self.eventsTextView.text += "\n\n========\n\nIntent creation failed:\n\(error)..."
                return
            }
            guard let intentID:String = intentResponse?["id"] as? String,
                  !intentID.isEmpty else{
                self.eventsTextView.text += "\n\n========\n\nIntent creation failed:\n\(String(describing: intentResponse))..."
                return
            }
            self.eventsTextView.text += "\n\n========\n\nIntent created with id: \n\(intentID)"
            PayButtonExample.exampleIntentId = intentID
            self.payButton.initPayButton(configDict: self.dictConfig, delegate: self)
        }
    }
}
