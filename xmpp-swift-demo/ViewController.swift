//
//  ViewController.swift
//  xmpp-swift-demo
//
//  Created by Navdip on 22/12/16.
//  Copyright © 2016 Navdip. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var txtMsg:UITextField?
    @IBOutlet var txtUserName:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSendMessahe() -> Void {
        (UIApplication.shared.delegate as! AppDelegate).sendMsgTest(strReceiver: self.txtUserName?.text, strMessage: self.txtMsg?.text)
    }
}

