//
//  FeedVC.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/3/16.
//  Copyright © 2016 develop. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var navigationBar: UINavigationBar!
    var newNavigationItem: UINavigationItem!
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = 350
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        DataService.ds.downLoadUsername()
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    print("Snap: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String,AnyObject>{
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
       // var img = UIImage(named: "settingsIcon")
        let titleStr = "Profile"
        let profileBtn = UIBarButtonItem(title: titleStr, style: .Plain, target: self, action: #selector(onProfileButtonPressed(_:)))
        
        if let font = UIFont(name: "NotoSans-Regular", size: 15) {
            profileBtn.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        profileBtn.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = profileBtn
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        let post = posts[indexPath.row]
        print(post.postDescription)
        
        var img: UIImage?
        var profileImg: UIImage?
        
        if let url = post.imageUrl{
            img = FeedVC.imageCache.objectForKey(url) as? UIImage
        }
        
        let url1 = post.creatorImgUrl
        profileImg = FeedVC.imageCache.objectForKey(url1) as? UIImage
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            
            cell.request?.cancel()
            
            cell.configureCell(post, img: img, userImage: profileImg)
            return cell
        }else{
            let cell = PostCell()
            cell.configureCell(post, img: img, userImage: profileImg)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageUrl == nil{
            return 200
        }else{
            return tableView.estimatedRowHeight
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
    
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != ""{
            if let img = imageSelectorImage.image where imageSelected == true{
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
                                                        self.postToFirebase(imgLink)
                                                    }
                                                }
                                            }
                                        } case .Failure(let error):
                                            print(error)
                                    }
                })
            }else{
                self.postToFirebase(nil)
            }
        }
    }
   
    func postToFirebase(imgUrl: String?){
        var post: Dictionary<String,AnyObject> = [
            "description" : postField.text!, "likes" : 0, "creatorUsername" : DataService.ds.CURRENT_USERNAME, "creatorImgUrl" : DataService.ds.CURRENT_IMG_URL
        ]
        
        if imgUrl != nil{
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        tableView.reloadData()
    }
    
    func onProfileButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier(SEGUE_PROFILE, sender: nil)
    }
}
