//
//  ProfileVC.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/7/16.
//  Copyright © 2016 develop. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    
    private var _newUsername: String!
    private var _ImagePicker: UIImagePickerController!
    private var _imageSelected: Bool!
    private var _savedImage: UIImage!
    private var _creatorImgUrl: String?
    
    override func viewDidLoad() {
        _ImagePicker = UIImagePickerController()
        _ImagePicker.delegate = self
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileImgTapped))
        tap.numberOfTapsRequired = 1
        profileImg.addGestureRecognizer(tap)
        profileImg.userInteractionEnabled = true
        _imageSelected = false
        
        let username = DataService.ds.CURRENT_USERNAME
        if username != ""{
            usernameField.text = username
        }
        
        _creatorImgUrl = DataService.ds.CURRENT_IMG_URL
        
        _savedImage = FeedVC.imageCache.objectForKey(_creatorImgUrl!) as? UIImage

        if _creatorImgUrl != ""{
            if _savedImage != nil{
                self.profileImg.image = self._savedImage
            }else{
                Alamofire.request(.GET, self._creatorImgUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil{
                        let img = UIImage(data: data!)!
                        self.profileImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self._creatorImgUrl!)
                    }
                    
                    
                })
            }
        }
        
    }

    @IBAction func onConfirmPressed(sender: UIButton){
        if usernameField.text != ""{
            _newUsername = usernameField.text
            DataService.ds.REF_USER_CURRENT.child("username").setValue(_newUsername)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func profileImgTapped(){
        navigationController?.presentViewController(_ImagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        profileImg.image = image
        _imageSelected = true
        uploadImage()
    }
    
    
    func uploadImage(){
        if let img = profileImg.image where _imageSelected == true{
            let urlStr = "https://post.imageshack.us/upload_api.php"
            let url = NSURL(string: urlStr)!
            //Convert to jpeg & compress by 80%(0.2)
            let imgData = UIImageJPEGRepresentation(img, 0.2)!
            //Convert Imageshack API key to data format
            let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
            //Convert Json to data format
            let keyJson = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            Alamofire.upload(.POST, url, multipartFormData: { MultipartFormData in
                MultipartFormData.appendBodyPart(data: keyData, name: "key")
                MultipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                MultipartFormData.appendBodyPart(data: keyJson, name: "format")
                },
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .Success(let upload, _, _):
                                    upload.responseJSON { response in
                                        if let info = response.result.value as? Dictionary<String, AnyObject> {
                                            if let links = info["links"] as? Dictionary<String, AnyObject> {
                                                if let imgLink = links["image_link"] as? String {
                                                    print("LINK: \(imgLink)")
                                                    
                                                    DataService.ds.REF_USER_CURRENT.child("creatorImgUrl").setValue(imgLink)
                                                    
                                                    
                                                    
                                                }
                                            }
                                        }
                                    } case .Failure(let error):
                                        print(error)
                                }
            })
        }
    }
    
}
