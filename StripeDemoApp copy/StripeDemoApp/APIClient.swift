//
//  APIClient.swift
//  StripeDemoApp
//
//  Created by Trenser01 on 03/10/24.
//


import UIKit
import Foundation
import StripeTerminal


// Example API client class for communicating with your backend
class APIClient: ConnectionTokenProvider {

    // For simplicity, this example class is a singleton
    static let shared = APIClient()
    static let backendUrl = URL(string: "http://127.0.0.1:3000")!
    // Fetches a ConnectionToken from your backend
    func fetchConnectionToken(_ completion: @escaping ConnectionTokenCompletionBlock) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        guard let url = URL(string: "http://127.0.0.1:3000/connection-token") else {
            fatalError("Invalid backend URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    // Warning: casting using `as? [String: String]` looks simpler, but isn't safe:
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let json = json,let secret = json["secret"] as? String {
                        completion(secret, nil)
                    }
                    else {
                        let error = NSError(domain: "com.stripe-terminal-ios.example",
                                            code: 2000,
                                            userInfo: [NSLocalizedDescriptionKey: "Missing `secret` in ConnectionToken JSON response"])
                        completion(nil, error)
                    }
                }
                catch {
                    completion(nil, error)
                }
            }
            else {
                let error = NSError(domain: "com.stripe-terminal-ios.example",
                                    code: 1000,
                                    userInfo: [NSLocalizedDescriptionKey: "No data in response from ConnectionToken endpoint"])
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    
    func capturePaymentIntent(_ paymentIntentId: String, completion: @escaping (String?,Error?) -> Void) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        let url = URL(string: "/capture_payment_intent", relativeTo: APIClient.backendUrl)!

        let parameters = "{\"payment_intent_id\": \"\(paymentIntentId)\"}"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.data(using: .utf8)

        let task = session.dataTask(with: request) {(data, response, error) in
           
            if let response = response as? HTTPURLResponse, let data = data {
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let json = json,let secret = json["id"] as? String {
                        completion(secret, nil)
                    }

                }catch let error{
                    completion(nil, error)
                    print(error.localizedDescription)
                }
            } else {
                completion(nil,error)
            }
        }
        task.resume()
    }

    
}

