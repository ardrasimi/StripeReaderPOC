//
//  ViewController.swift
//  DemoApp
//
//  Created by Abilash Joseph  on 30/09/24.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var paymentTypeArr : [String] = ["Normal Payment","Stripe Terminal"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentTypeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RowTableViewCell", for: indexPath) as? RowTableViewCell else { return UITableViewCell() }
        cell.PaymenType.text = "\(paymentTypeArr[indexPath.row])"
        cell.ConnectedImage.alpha = 0.0
        return cell
       
    }
  
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.performSegue(withIdentifier: "NormalPay", sender: nil)
        }else{
            self.performSegue(withIdentifier: "StripeTerminalPay", sender: nil)
        }
    }
    
    
    

    @IBOutlet weak var TableViewOutlet: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Demo App"
        
        // Do any additional setup after loading the view.
        TableViewOutlet.delegate = self
        TableViewOutlet.dataSource = self
        TableViewOutlet.register(UINib(nibName: "RowTableViewCell", bundle: nil), forCellReuseIdentifier: "RowTableViewCell")
            }
    
    }



extension UIView {
    static let loadingViewTag = 1938123987
    func showLoading(style: UIActivityIndicatorView.Style = .large) {
        var loading = viewWithTag(UIImageView.loadingViewTag) as? UIActivityIndicatorView
        if loading == nil {
            loading = UIActivityIndicatorView(style: style)
        }

        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingViewTag
        addSubview(loading!)
      loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func stopLoading() {
        let loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        loading?.stopAnimating()
        loading?.removeFromSuperview()
    }
}
extension UIView{
 /**
     ShowLoader:  loading view ..

     - parameter Color:  ActivityIndicator and view loading color .

     */
    
    
    func showLoader(_ color:UIColor?){


        let LoaderView  = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        LoaderView.tag = 888754
        LoaderView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        let Loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        Loader.center = LoaderView.center
        Loader.style = .large
        Loader.color = UIColor.gray
        Loader.startAnimating()
        LoaderView.addSubview(Loader)
        self.addSubview(LoaderView)
    }

 /**
     dismissLoader:  hidden loading view  ..
     */
    func dismissLoader(){


        self.viewWithTag(888754)?.removeFromSuperview()
    }
}
