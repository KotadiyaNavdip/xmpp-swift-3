//
//  AppDelegate.swift
//  xmpp-swift-demo
//
//  Created by Navdip on 22/12/16.
//  Copyright © 2016 Navdip. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPRosterDelegate, XMPPStreamDelegate {

    var window: UIWindow?
    
    let xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster
    
    let strHostName =  "" // like 192.168.1.1
    var strUserName = "admin"
    let strPassword = "admin"

    override init() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage as XMPPRosterStorage!)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        strUserName = "\(strUserName)@\(strHostName)"
        print(strUserName)
        DDLog.add(DDTTYLogger.sharedInstance())
        xmppStream?.hostName = "\(strHostName)"
        xmppStream?.hostPort = 5222
        setupStream()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        disconnect()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        _ = connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupStream() {
        //xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.activate(xmppStream)
        xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func goOnline() {
        let presence = XMPPPresence(
        )
        let domain = xmppStream?.myJID.domain
        
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
            let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
            presence?.addChild(priority)
        }
        xmppStream?.send(presence)
    }
    
    func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream?.send(presence)
    }
    
    func connect() -> Bool {
        if !(xmppStream?.isConnected())! {
            
            if !(xmppStream?.isDisconnected())! {
                return true
            }
            print(XMPPJID(string: strUserName))
            xmppStream?.myJID = XMPPJID(string: strUserName)
            
            do {
                try xmppStream?.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    func disconnect() {
        goOffline()
        xmppStream?.disconnect()
    }
    
    //MARK: XMPP Delegates
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        do {
            try	xmppStream?.authenticate(withPassword: strPassword)
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        goOnline()
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        print("Did receive message \(message) \n \n \n")
        print("Body :- \(message.body())")
        print("Subject :- \(message.subject())")
        print("Thread :- \(message.thread())")
        print("Type :- \(message.type()) \n\n\n\n")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceiveError error: DDXMLElement!) {
        print("Did receive error \(error)")
    }
    
    func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        print("Did send message \(message.elementID())")
    }
    
    func xmppRoster(_ sender: XMPPRoster!, didReceivePresenceSubscriptionRequest presence: XMPPPresence!) {
        
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != myUsername {
            print("Did receive presence from \(presenceFromUser)")
        }
    }
    
    func xmppRoster(_ sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        print("Did receive Roster item")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        
    }
    
    func sendMsgTest(strReceiver:String!, strMessage:String!) -> Void {
        let strThread = ""
        let strType = "chat"
        
        let strReceivers = strReceiver+"@\(strHostName)"
        
        
        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
        body.stringValue = strMessage
        
        let messageID = xmppStream?.generateUUID()
        
        let threadElement = DDXMLElement.element(withName: "thread") as! DDXMLElement
        threadElement.stringValue = strThread
        
        let completeMessage = DDXMLElement.element(withName: "message") as! DDXMLElement
        
        completeMessage.addAttribute(withName: "id", stringValue: messageID!)
        completeMessage.addAttribute(withName: "type", stringValue: strType)
        completeMessage.addAttribute(withName: "to", stringValue: strReceivers)
        completeMessage.addChild(body)
        completeMessage.addChild(threadElement)
        xmppStream?.send(completeMessage)
    }
}

