import UIKit

// global var  referring to appDelegate to be called from any class
let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

let redSmoothColor = UIColor(red: 255/255, green: 50/255, blue: 75/255, alpha: 1)
let lightGreenSmoothColor = UIColor(red: 230/255, green: 244/255, blue: 125/255, alpha: 1)
let brandBlueColor = UIColor(red: 45 / 255, green: 213 / 255, blue: 255 / 255, alpha: 1)

let fontSize12 = UIScreen.main.bounds.width / 31

var user: NSDictionary?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //image to be animated
    let backgroundImage = UIImageView()

    // bool to check if errorView is currently showing or not
    var infoViewIsShowing: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // creating image view to store background image
        backgroundImage.frame = CGRect(x: 0, y: 0, width: self.window!.bounds.height * 1.688, height: self.window!.bounds.height)
        backgroundImage.image = UIImage(named: "mainbg.jpg")
        self.window!.addSubview(backgroundImage)
        
        moveBgLeft()
        
        // load content in user var
        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
        
        // if user is registered & logged in, keep them logged in
        if user != nil {
            let id = user!["id"] as? String
            
            if id != nil {
                logIn()
            }
        }
        
        return true
    }
    
    func moveBgLeft() {
        UIView.animate(withDuration: 45, animations: { 
            self.backgroundImage.frame.origin.x = -self.backgroundImage.bounds.width + self.window!.bounds.width
        }) { (finished: Bool) in
            if finished {
                self.moveBgRight()
            }
        }
    }
    
    func moveBgRight() {
        UIView.animate(withDuration: 45, animations: { 
            self.backgroundImage.frame.origin.x = 0
        }) { (finished: Bool) in
            if finished {
                self.moveBgLeft()
            }
        }
    }
    
    func infoView(mesage message: String, color: UIColor) {
        
        if infoViewIsShowing == false {
            
            infoViewIsShowing = true
            let infoViewHeight = self.window!.bounds.height / 14.2
            let infoViewY = 0 - infoViewHeight
            
            let infoView = UIView(frame: CGRect(x: 0, y: infoViewY, width: self.window!.bounds.width, height: infoViewHeight))
            infoView.backgroundColor = color
            self.window!.addSubview(infoView)
            
            let infoLabelHeight = infoView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
            let infoLabelWidth = infoView.bounds.width
            
            let infoLabel = UILabel()
            infoLabel.frame.size.width = infoLabelWidth
            infoLabel.frame.size.height = infoLabelHeight
            infoLabel.numberOfLines = 0
            
            infoLabel.text = message
            infoLabel.font = UIFont(name: "HelveticaNeue", size: fontSize12)
            infoLabel.textColor = UIColor.white
            infoLabel.textAlignment = .center
            
            infoView.addSubview(infoLabel)
            
            // animate
            UIView.animate(withDuration: 0.2, animations: {
                // move the view down
                infoView.frame.origin.y = 0
            }, completion: { (finished: Bool) in
                if finished {
                    UIView.animate(withDuration: 0.1, delay: 4, options: .curveLinear, animations: {
                        infoView.frame.origin.y = -infoLabelHeight
                    }, completion: { (finished) in
                        if finished {
                            infoView.removeFromSuperview()
                            infoView.removeFromSuperview()
                            self.infoViewIsShowing = false
                        }
                    })
                }
            })
        }
        
    }
    
    func logIn() {
        // make a reference to our storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // store tabBar object from main.storyboard
        let tabBar = storyboard.instantiateViewController(withIdentifier: "tabBar")
        
        // present tabBar 
        window?.rootViewController = tabBar
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

