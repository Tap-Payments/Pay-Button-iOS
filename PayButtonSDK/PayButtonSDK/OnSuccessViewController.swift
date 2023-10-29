//
//  OnSuccessViewController.swift
//  BenefitPayExampleApp
//
//  Created by Osama Rabie on 14/10/2023.
//

import UIKit


class OnSuccessViewController: UIViewController {

    
    @IBOutlet weak var textView: UITextView!
    var string:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = string
        // Do any additional setup after loading the view.
    }
    @IBAction func copyClicked(_ sender: Any) {
        let items = [string]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    @IBAction func dismissClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
