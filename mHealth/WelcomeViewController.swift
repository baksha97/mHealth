//
//  WelcomeViewController.swift
//  mHealth
//
//  Created by Loaner on 3/2/17.
//  Copyright © 2017 JTMax. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var s1: UITextField!
    @IBOutlet weak var s2: UITextField!
    @IBOutlet weak var button: UIButton!
    
    //MARK:Firebase
    let user = FIRAuth.auth()?.currentUser
    let ref = FIRDatabase.database().reference(withPath: "users")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if(user?.displayName == nil){
            let alert = UIAlertController(title: "Hello!",
                                          message: "We see you're new...",
                                          preferredStyle: .alert)
            alert.addTextField { displayNamer in
                displayNamer.placeholder = "Enter your permanent display name"
                let changeRequest = self.user?.profileChangeRequest()
                changeRequest?.displayName = displayNamer.text
            }
            let okAction = UIAlertAction(title: "Okay",
                                         style: .default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } */
        /* this doesn't work and I'm not sure how to add a display name convientenly to sort data in the firebase table inside of console.... currently it's being stored as 
         "Opinional("\(uid)") */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func buttonDidTouch(_ sender: Any) {
        
        let c = s1.text
        let f = s2.text
        
        let newFavorite: favorite = favorite(color: c!, friend: f!)
        
        let userRef = self.ref.child("\(user?.uid)")
        print("\(user?.uid)")
        userRef.setValue(newFavorite.toAnyObject())
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
