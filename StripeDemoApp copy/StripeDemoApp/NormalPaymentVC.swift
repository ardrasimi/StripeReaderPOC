//
//  NormalPaymentVC.swift
//  DemoApp
//
//  Created by Abilash Joseph  on 30/09/24.
//

import UIKit
import StripePaymentSheet

class NormalPaymentVC: UIViewController {
    var paymentIntentID : String = ""
    var PayemntSheet: PaymentSheet?
    
    @IBOutlet weak var RefundButton: UIButton!
    @IBOutlet weak var PayButton: UIButton!
    
    var isPaymentStarted = false
    @IBAction func PayButtonAction(_ sender: UIButton) {
        isPaymentStarted = true
        self.SetUpView()
        var PaymentIntentID = ""
        NormalPaymentVC.startCheckUp(destination: "payment-sheet") { Str,json in
            if let customerId = json["customer"] as? String,
               let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
               let paymentIntentClientSecret = json["paymentIntent"] as? String,
               let paymentIntentSt = json["paymentIntentSt"]{
                
                if let paymentIntentst = paymentIntentSt as? [String:Any]{
                    if let paymentIntentID = paymentIntentst["id"] as? String{
                        PaymentIntentID = paymentIntentID
                        print("paymentIntentID : \(paymentIntentID)")
                    }
                }
                
                STPAPIClient.shared.publishableKey = PublishableKey
                // MARK: Create a PaymentSheet instance
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Stripe Demo App"
                configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                // Set `allowsDelayedPaymentMethods` to true if your business handles
                // delayed notification payment methods like US bank accounts.
                configuration.allowsDelayedPaymentMethods = true
                DispatchQueue.main.async {
                    self.PayemntSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
                    
                   
                        self.PayemntSheet!.present(from: self, completion: { paymentResult in
                            var message: String
                            switch paymentResult {
                            case .completed:
                                self.paymentIntentID = PaymentIntentID
                                message = "Completed"
                            case .canceled:
                                message = "Cancelled"
                            case .failed(let error):
                                message = "failed \(error.localizedDescription)"
                            }
                            self.showDialog(message: message, ViewController: self, Completion: {
                                
                                self.isPaymentStarted = false
                                self.SetUpView()
                            })
                        })
                    
                }
            }
        }

    }
    
    @IBAction func RefundButtonAction(_ sender: UIButton) {
        isPaymentStarted = true
        self.SetUpView()
        let dict : [String : Any] = ["payment_Intent":"\(paymentIntentID)"]
        NormalPaymentVC.startCheckUp(parameters: dict,destination: "refunds") { string,Dict in
            print(Dict)
            if let refunds = Dict["refunds"] as? [String:Any]{
                if let status = (refunds["status"] as? String){
                    DispatchQueue.main.async{
                        self.showDialog(message: status, ViewController: self, Completion: {
                            self.isPaymentStarted = false
                            self.SetUpView()
                        })
                    }
                }
            }else{
                DispatchQueue.main.async{
                    self.showDialog(message: "failed", ViewController: self, Completion: {
                        self.isPaymentStarted = false
                        self.SetUpView()
                    })
                }
            }
        }
    }
    
    
    static func startCheckUp(parameters: [String:Any] = [:],destination:String,completion : @escaping (String,NSDictionary) -> Void){
        
        if let url = URL(string: "http://127.0.0.1:3000/\(destination)"){
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                   return
               }
            request.httpBody = httpBody
            URLSession.shared.dataTask(with: request) { Data, URLResponse, Error in
                do{
                    if let Data = Data{
                        let parsedData = try JSONSerialization.jsonObject(with: Data, options: .allowFragments)
                        if let dict = parsedData as? NSDictionary{
                            completion("\(destination)",dict)
                        }
                    }else{
                        print("nil")
                    }
                }catch let error{
                    print(error.localizedDescription)
                }
            }.resume()
        }
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func SetUpView(){
        if paymentIntentID.isEmpty{
            RefundButton.isEnabled = false
            RefundButton.alpha = 0.5
            
        }else{
            RefundButton.isEnabled = true
            RefundButton.alpha = 1
        }
        if isPaymentStarted{
            
            self.view.showLoader(UIColor.gray)
//            LoadingView.alpha = 1.0
        }else{
            self.view.dismissLoader()
        
        }

    }
}
extension UIViewController{
    func showDialog(message: String,ViewController:UIViewController,Completion : @escaping () -> Void) {
      let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            Completion()
        }))
      ViewController.present(alertController, animated: true)
  }

}
