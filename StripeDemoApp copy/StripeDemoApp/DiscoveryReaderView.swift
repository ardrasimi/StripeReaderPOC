//
//  DiscoveryReaderView.swift
//  DemoApp
//
//  Created by Abilash Joseph  on 30/09/24.
//

import UIKit
import StripeTerminal



class DiscoveryReaderView: UIViewController, DiscoveryDelegate, UITableViewDelegate, UITableViewDataSource, TerminalDelegate, BluetoothReaderDelegate  {
    
    var discoverCancelable: Cancelable?
    var readersList: [Reader] = []
    
    @IBAction func RefundButtonAction(_ sender: Any) {
        self.isPayementProcessing = true
        self.setupView()

        let dict : [String : Any] = ["payment_Intent":"\(PaymentIntentId)"]
        NormalPaymentVC.startCheckUp(parameters: dict,destination: "refunds") { string,Dict in
            print(Dict)
            if let refunds = Dict["refunds"] as? [String:Any]{
                if let status = (refunds["status"] as? String){
                    DispatchQueue.main.async{
                        self.showDialog(message: status, ViewController: self, Completion: {
                            self.isPayementProcessing = false
                            self.setupView()

                        })
                    }
                }
            }else{
                DispatchQueue.main.async{
                    self.showDialog(message: "failed", ViewController: self, Completion: {
                        self.isPayementProcessing = false
                        self.setupView()

                    })
                }
            }
        }

    }
    
    @IBOutlet weak var RefundButtionLbn: UIButton!
    
    @IBAction func PayButtonAction(_ sender: Any) {
//        if let selectedReader = selectedReader{
//            print(selectedReader.serialNumber)
        isPayementProcessing = true
        setupView()
            do{
                let params = try PaymentIntentParametersBuilder(amount: 10000,
                                                                currency: "usd")
                    .setPaymentMethodTypes(["card_present"])
                    .build()
                Terminal.shared.createPaymentIntent(params) {
                  createResult, createError in
                    if let error = createError {
                        print("createPaymentIntent failed: \(error)")
                    } else if let paymentIntent = createResult {
                        print("createPaymentIntent \(paymentIntent)")
                        Terminal.shared.collectPaymentMethod(paymentIntent) { collectResult, collectError in
                            if let error = collectError {
                                print("collectPaymentMethod failed: \(error)")
                            } else if let paymentIntent = collectResult {
                                print("collectPaymentMethod succeeded")

                                self.confirmPaymentIntent(paymentIntent)
                            }
                        }
                    }
                }

            }catch let error{
                print(error.localizedDescription)
            }

//        }
    }
    
    @IBOutlet weak var PayButtonOutlet: UIButton!
    @IBOutlet weak var TableView: UITableView!
    
    var isPayementProcessing = false
    var PaymentIntentId = ""
    var selectedReader : Reader?
    var seletecdIndex = 0
    func setupView(){
        if selectedReader != nil{
            PayButtonOutlet.alpha = 1.0
            PayButtonOutlet.isEnabled = true
            if !PaymentIntentId.isEmpty{
                RefundButtionLbn.alpha = 1.0
                RefundButtionLbn.isEnabled = true
            }
        }else{
            PayButtonOutlet.alpha = 0.5
            PayButtonOutlet.isEnabled = false
            RefundButtionLbn.alpha = 0.5
            RefundButtionLbn.isEnabled = false
        }
        if isPayementProcessing{
            
            self.view.showLoader(UIColor.gray)
        }else{
            self.view.dismissLoader()
        
        }
    }
    
    func confirmPaymentIntent(_ paymentIntent: PaymentIntent) {
        Terminal.shared.confirmPaymentIntent(paymentIntent) { confirmResult, confirmError in
            if let error = confirmError {
                print("confirmPaymentIntent failed: \(error)")
            } else if let confirmedPaymentIntent = confirmResult {
                print("confirmPaymentIntent succeeded")
                if let stripeId = confirmedPaymentIntent.stripeId {
                    
                    // Notify your backend to capture the PaymentIntent.
                    // PaymentIntents processed with Stripe Terminal must be captured
                    // within 24 hours of processing the payment.
                    
                    APIClient.shared.capturePaymentIntent(stripeId) { PatmentIntent,error in
                        if let PatmentIntent = PatmentIntent {
                            self.showDialog(message: "Payment succeeded", ViewController: self) {
                                self.PaymentIntentId = PatmentIntent
                                self.isPayementProcessing = false
                                self.setupView()

                            }
                        } else if let error = error {
                            
                            self.showDialog(message: error.localizedDescription, ViewController: self) {
                                self.isPayementProcessing = false
                                self.setupView()

                            }
                        }
                    }
                    

                } else {
                    self.showDialog(message: "Payment collected offline", ViewController: self) {
                        self.PaymentIntentId = paymentIntent.stripeId!
                        self.isPayementProcessing = false
                        self.setupView()
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.selectedReader = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        setupView()
        do{
           try discoverReaders()
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        Terminal.shared.delegate = self
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "RowTableViewCell", bundle: nil), forCellReuseIdentifier: "RowTableViewCell")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        readersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RowTableViewCell", for: indexPath) as? RowTableViewCell else { return UITableViewCell() }
        cell.PaymenType.text = "\(readersList[indexPath.row].serialNumber)"
        if selectedReader != nil, seletecdIndex == indexPath.row {
            cell.ConnectedImage.alpha = 1.0
        }else{
            cell.ConnectedImage.alpha = 0.0
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReader = readersList[indexPath.row]
        seletecdIndex = indexPath.row
        connectToReader(reader: selectedReader!)
        setupView()
        self.TableView.reloadData()
    }

    
    func discoverReaders() throws {
        let config = try BluetoothScanDiscoveryConfigurationBuilder().setSimulated(true).build()
        self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { error in
            if let error = error {
                print("discoverReaders failed: \(error)")
            } else {
                print("discoverReaders succeeded")
            }
        }
    }
    
    
    func connectToReader(reader: Reader){
        //guard let selectedReader = readers.first else { return }
        
        // Since the simulated reader is not associated with a real location, we recommend
        // specifying its existing mock location.
        guard let locationId = reader.locationId else { return }
        
        // Only connect if we aren't currently connected.
        //guard Terminal.connectionStatus == .notConnected else { return }
        
        let connectionConfig: BluetoothConnectionConfiguration
        do {
            connectionConfig = try BluetoothConnectionConfigurationBuilder(
                // When connecting to a physical reader, your integration should specify either the
                // same location as the last connection (selectedReader.locationId) or a new location
                // of your user's choosing.
                //
                locationId: locationId
            ).build()
        } catch {
            // Handle error building the connection configuration
            return
        }
        
        // Note `readerDelegate` should be provided by your application.
        // See our Quickstart guide at https://stripe.com/docs/terminal/quickstart
        // for more example code.
       
        Terminal.shared.connectBluetoothReader(reader, delegate: self, connectionConfig: connectionConfig) { reader, error in
            if let reader = reader {
                print("Successfully connected to reader: \(reader)")
            } else if let error = error {
                print("connectReader failed: \(error)")
            }
        }
    }
    
    func DisconnectReader() async{
        do {
            try await Terminal.shared.disconnectReader()
        }catch let error{
            print(error.localizedDescription)
        }
    }
}

extension DiscoveryReaderView{
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        readersList = readers
        TableView.reloadData()
        print(#function)
    }
    
    func terminal(_ terminal: Terminal, didReportUnexpectedReaderDisconnect reader: Reader) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: (any Error)?) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
        print(#function)
    }
    
    func reader(_ reader: Reader, didDisconnect reason: DisconnectReason) {
        print(#function)
    }

}
