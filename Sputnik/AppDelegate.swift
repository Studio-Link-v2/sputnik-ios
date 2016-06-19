/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	The application delegate.
*/

import UIKit
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {

    class var shared: AppDelegate {
        return UIApplication.shared().delegate as! AppDelegate
    }

    var window: UIWindow?
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = SpeakerboxCallManager()
    var providerDelegate: ProviderDelegate?

    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("Finished launching with options: \(launchOptions)")

        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voip]

        providerDelegate = ProviderDelegate(callManager: callManager)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [String : AnyObject]) -> Bool {
        guard let handle = url.startCallHandle else {
            print("Could not determine start call handle from URL: \(url)")
            return false
        }

        callManager.startCall(handle: handle)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard let handle = userActivity.startCallHandle else {
            print("Could not determine start call handle from user activity: \(userActivity)")
            return false
        }

        callManager.startCall(handle: handle)
        return true
    }

    // MARK: PKPushRegistryDelegate

    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        /*
            Store push credentials on server for the active user.
            For sample app purposes, do nothing since everything is being done locally.
         */
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        guard type == .voip else { return }

        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
           let handle = payload.dictionaryPayload["handle"] as? String,
           let uuid = UUID(uuidString: uuidString)
        {
            displayIncomingCall(uuid: uuid, handle: handle)
        }
    }

    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String) {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle)
    }

}
