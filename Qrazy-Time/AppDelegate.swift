import UIKit
import AppsFlyerLib
import FirebaseCore
import FirebaseAnalytics
import FBSDKCoreKit
import UserNotifications
import AppTrackingTransparency
import AdSupport
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    //DEVELOPER MODE
    let appsFlyerDevKey = "LbSAnvCDRqtFBTGvL9i8dV"
    let appleAppId = "6473779790"
    
    var oldAndNotWorkingnaming: [String : Any] = [:]
    var iDontKnowWhyButThisAttributionData: [String : Any] = [:]
    
    var window: UIWindow?
    
    var attributionData = ""
    var naming = ""
    var facebookDeepLink = ""
    var deep_link_sub1 = ""
    var deep_link_sub2 = ""
    var deep_link_sub3 = ""
    var deep_link_sub4 = ""
    var deep_link_sub5 = ""
    var deepLinkStr = ""
    var token = ""
    var idfa = ""
    var id =  ""
    
    let localeLocalizationCode = NSLocale.current.languageCode
    
    func currentTimeZone() -> String {
        return TimeZone.current.identifier
    }
    
    var localizationTimeZoneAbbrtion: String {
        return TimeZone.current.abbreviation() ?? ""
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        faceSDK()
        createGoogleFirebase()
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppId
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().delegate = self
        id = AppsFlyerLib.shared().getAppsFlyerUID()
        
        UNUserNotificationCenter.current().delegate  = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {
            success, error in
            guard success else {
                return
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        })
        Messaging.messaging().delegate = self

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    func createGoogleFirebase() {
        FirebaseApp.configure()
    }
    
    //MARK: - Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        token = tokenParts.joined()
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.token = "Error"
        print("\(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
          }
        }
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .denied:
                    print("AuthorizationSatus is denied")
                case .notDetermined:
                    print("AuthorizationSatus is notDetermined")
                case .restricted:
                    print("AuthorizationSatus is restricted")
                case .authorized:
                    print("AuthorizationSatus is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
                self.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                DispatchQueue.main.async {
                    (self.window?.rootViewController as? LoadingViewController)?.sendToRequest()
                    (self.window?.rootViewController as? LoadingViewController)?.ourResponse = 1
                }
            })
        } else {
            self.id = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        
        return true
        
    }
    
    func faceSDK() {
        
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
            if let error = error {
                print("Received error while fetching deferred app link %@", error)
            }
            if let url = url {
                self.facebookDeepLink = url.absoluteString
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
        }
    }
    
    
    
}

extension AppDelegate: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        
        switch result.status {
        case .notFound:
            NSLog("[AFSDK] Deep link not found")
            
            return
        case .failure:
            print("Error %@", result.error!)
            return
        case .found:
            NSLog("[AFSDK] Deep link found")
        }
        
        guard let deepLinkObj:DeepLink = result.deepLink else {
            NSLog("[AFSDK] Could not extract deep link object")
            return
        }
        
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub2") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub2"] as! String
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
            
            self.deep_link_sub2 = ReferrerId
            
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub3") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub3"] as! String
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
            
            self.deep_link_sub3 = ReferrerId
            print("WWWWWWWWWWWWWWWWWW: \(ReferrerId)")
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub4") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub4"] as! String
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
            
            self.deep_link_sub4 = ReferrerId
            
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub5") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub5"] as! String
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
            
            self.deep_link_sub5 = ReferrerId
            
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub1") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub1"] as! String
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
            
            self.deep_link_sub1 = ReferrerId
            
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        
        let deepLinkStr:String = deepLinkObj.toString()
        NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
        
        self.deepLinkStr = deepLinkStr
        
        if( deepLinkObj.isDeferred == true) {
            NSLog("[AFSDK] This is a deferred deep link")
        }
        else {
            NSLog("[AFSDK] This is a direct deep link")
        }
        
    }
}

//MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate{
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        
        oldAndNotWorkingnaming = installData as! [String : Any]
        
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    //Handle Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        self.iDontKnowWhyButThisAttributionData = attributionData as! [String : Any]
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
extension AppDelegate: MessagingDelegate {
    
}


