//
//  PostCell.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/3/16.
//  Copyright © 2016 develop. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
   
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    }

    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        mainImg.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(post: Post, img : UIImage?, userImage: UIImage?){
        self.post = post
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.usernameLbl.text = post.creatorUsername
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        if post.imageUrl != nil{
            
            if img != nil {
                self.mainImg.image = img
            }else{
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil{
                        let img = UIImage(data: data!)!
                        self.mainImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                
                
                })
                
            }
        }else{
            self.mainImg.hidden = true
        }
        
        
        if post.creatorImgUrl != ""{
            print("Not Nil!")
            print(post.creatorImgUrl)
            if userImage != nil {
                self.profileImg.image = userImage
            }else{
            request = Alamofire.request(.GET, post.creatorImgUrl).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil{
                        let img = UIImage(data: data!)!
                        self.profileImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.creatorImgUrl)
                    }
                
                })
            }
        }

        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot  in
            
            //In firebase if there is no data in (.value) a NSNUll will be returned
            if let doesNotExist = snapshot.value as? NSNull{
                //We have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty")
            }else{
                self.likeImg.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot  in
            
            //In firebase if there is no data in (.value) a NSNUll will be returned
            if let doesNotExist = snapshot.value as? NSNull{
                //We have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            }else{
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })

    }

}
