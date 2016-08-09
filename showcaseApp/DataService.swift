//
//  DataService.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/1/16.
//  Copyright © 2016 develop. All rights reserved.
//

import Foundation
import Firebase

//Gets url from the google service info p list
let URL_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS =  URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    private var _USERNAME: String!
    private var _CURRENT_IMG_URL: String!
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var CURRENT_USERNAME: String{
        if _USERNAME != nil{
        return _USERNAME
        }else{
            return ""
        }
    }
    
    var CURRENT_IMG_URL:String{
        if _CURRENT_IMG_URL != nil{
            return _CURRENT_IMG_URL
        }else{
        return ""
        }
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    
    func downLoadUsername(){
    DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
            if let userDict = snapshot.value as? Dictionary<String,AnyObject>{
                if let username = userDict["username"] as? String{
                    self._USERNAME = username
                    let str = "usernameDownloaded"
                    NSNotificationCenter.defaultCenter().postNotificationName(str, object: nil)
                }
                if let userImgUrl = userDict["creatorImgUrl"] as? String{
                    self._CURRENT_IMG_URL = userImgUrl
                }
            }
    })
    }
    
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        
        REF_USERS.child(uid).updateChildValues(user)
        
    }
    
}