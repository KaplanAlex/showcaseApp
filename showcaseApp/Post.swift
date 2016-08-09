//
//  Post.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/3/16.
//  Copyright © 2016 develop. All rights reserved.
//

import Foundation
import Firebase

class Post{
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _creatorUsername: String!
    private var _creatorImgUrl: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String{
        return _postDescription
    }
    
    var imageUrl: String?{
        return _imageURL
    }
    
    var likes: Int{
        return _likes
    }
    
    var creatorUsername: String?{
        return  _creatorUsername
    }
    
    var postKey: String{
        return _postKey
    }
    
    var creatorImgUrl: String{
        return _creatorImgUrl
    }
    
    init(description: String, imageUrl: String?, username: String){
        self._postDescription = description
        self._imageURL = imageUrl
        self._creatorUsername = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        //Same keys as in firebase
        if let likes = dictionary["likes"] as? Int{
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String{
            self._imageURL = imgUrl
        }
        
        if let desc = dictionary["description"] as? String{
            self._postDescription = desc
        }
        
        if let creatorUsername = dictionary["creatorUsername"] as? String{
            self._creatorUsername = creatorUsername
        }
        
        if let creatorImgUrl = dictionary["creatorImgUrl"] as? String{
            self._creatorImgUrl = creatorImgUrl
        }else{
            self._creatorImgUrl = ""
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
        
    }
    
    func adjustLikes(addLike: Bool){
        if addLike{
            _likes = _likes + 1
        }else{
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
    
}