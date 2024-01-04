//
//  CreateAuthTokenViewController.swift
//  PayButtonSDK
//
//  Created by Osama Rabie on 14/11/2023.
//

import UIKit
/*import Card_iOS

protocol CreateAuthDelegate {
    func didFail(with response:String)
    func didSucceed(with authID:String, customerID:String, orderID:String, sourceID:String)
}

class CreateAuthTokenViewController: UIViewController, TapCardViewDelegate {
    
    /// An instance of the card fiew
    var tapCardView:TapCardView = .init()
    var delegate:CreateAuthDelegate?
    var amount:Double = 1
    var currency:String = "SAR"
    var cardNumber:String = "4242424242424242"
    /// The minimum needed configuration dictionary
    var parameters: [String: Any] {
        return [
            "operator": ["publicKey": "pk_test_YhUjg9PNT8oDlKJ1aE2fMRz7"],
            "scope": "AuthenticatedToken",
            "purpose":"Transaction",
            "order": [
                "amount": amount,
                "currency": currency,
                "metadata": ["key": "value"],
            ],
            "customer": [
                "name": [["lang": "en", "first": "TAP", "middle": "", "last": "PAYMENTS"]],
                "contact": [
                    "email": "tap@tap.company",
                    "phone": ["countryCode": "+965", "number": "88888888"],
                ],
            ],
        ]
    }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         // Do any additional setup after loading the view.
         
         // First of all, add it to your view
         view.addSubview(tapCardView)
         // Make it adjusttable to manual constraints
         tapCardView.translatesAutoresizingMaskIntoConstraints = false
         // Please it is a must to set the constraints, don't asssign a height constraint to allow the card to adapt dynamically.
         // We are now assigning the recommended width constraints to be full width with 10px margins
         NSLayoutConstraint.activate([
             tapCardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
             tapCardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
             tapCardView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40),
         ])
     }
     
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We provide the card view the needed parameters and we assign ourselves optionally to be the delegate, where we can listen to callbacks.
        tapCardView.initTapCardSDK(configDict: self.parameters, delegate: self,cardNumber: cardNumber, cardExpiry: "12/24")
    }
     /**
         Will be fired whenever the card sdk finishes successfully the task assigned to it. Whether `TapToken` or `AuthenticatedToken`
      - Parameter data: will include the data in JSON format. For `TapToken`:
      {
          "id": "tok_MrL97231045SOom8cF8G939",
          "created": 1694169907939,
          "object": "token",
          "live_mode": false,
          "type": "CARD",
          "source": "CARD-ENCRYPTED",
          "used": false,
          "card": {
              "id": "card_d9Vj7231045akVT80B8n944",
              "object": "card",
              "address": {},
              "funding": "CREDIT",
              "fingerprint": "gRkNTnMrJPtVYkFDVU485Gc%2FQtEo%2BsV44sfBLiSPM1w%3D",
              "brand": "VISA",
              "scheme": "VISA",
              "category": "",
              "exp_month": 4,
              "exp_year": 24,
              "last_four": "4242",
              "first_six": "424242",
              "name": "AHMED",
              "issuer": {
                 "bank": "",
                 "country": "GB",
                 "id": "bnk_TS07A0720231345Qx1e0809820"
             }
          },
          "url": ""
      }
      */
     func onSuccess(data: String) {
         // let us check if we can parse it as json first
         guard let jsonObject:[String:Any] = try? JSONSerialization.jsonObject(with: data.data(using: .utf8) ?? .init()) as? [String:Any],
               let authID:String = jsonObject["id"] as? String,
               let authResult:String = jsonObject["status"] as? String, authResult.uppercased() == "AUTHENTICATED",
               let orderID:String = (jsonObject["order"] as? [String:Any])?["id"] as? String,
               let customerID:String = (jsonObject["customer"] as? [String:Any])?["id"] as? String,
               let sourceID:String = (jsonObject["source"] as? [String:Any])?["id"] as? String else {
             
             dismiss(animated: true) {
                 self.delegate?.didFail(with: data)
             }
             
             return
         }
         
         
         dismiss(animated: true) {
             self.delegate?.didSucceed(with: authID, customerID: customerID, orderID: orderID, sourceID: sourceID)
         }
         
         
         print(data)
     }
     
     /// Will be fired whenever there is an error related to the card connectivity or apis
     /// - Parameter data: includes a JSON format for the error description and error
     
     func onError(data: String) {
         print(data)
         dismiss(animated: true) {
             self.delegate?.didFail(with: data)
         }
     }
     
     func onInvalidInput(invalid: Bool) {
         if !invalid {
             tapCardView.generateTapToken()
         }
     }
     // Will be fired whenever the card element changes its height for your convience
     /// - Parameter height: The new needed height
     func onHeightChange(height: Double) {
         print("NEW HEIGHT \(height)")
     }
     
     
     /// Will be fired whenever the card is rendered and loaded
     func onReady() {
         print("Card is read")
     }
     
     /// Will be fired once the user focuses any of the card fields
     func onFocus() {
         print("Card is focused")
     }
     
     /// Will be fired once we detect the brand and related issuer data for the entered card data
     /** - Parameter data: will include the data in JSON format. example :
      *{
         "bin": "424242",
         "bank": "",
         "card_brand": "VISA",
         "card_type": "CREDIT",
         "card_category": "",
         "card_scheme": "VISA",
         "country": "GB",
         "address_required": false,
         "api_version": "V2",
         "issuer_id": "bnk_TS02A5720231337s3YN0809429",
         "brand": "VISA"
      }*     */
     func onBinIdentification(data: String) {
         print(data)
     }
 }

*/
