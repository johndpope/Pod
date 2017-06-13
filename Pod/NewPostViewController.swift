//
//  NewPostViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import AWSFacebookSignIn
import AWSS3
import AWSCognitoIdentityProvider
import AWSMobileHubHelper
import AWSCore
import AWSCognito


class NewPostViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var textBackgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var postPhotoButton: UIImageView!
    @IBOutlet weak var postPollButton: UIButton!
    
    // MARK: - Properties
    
    fileprivate lazy var pollTableView: UITableView = {
        let pollTableView = UITableView()
        pollTableView.separatorStyle = .none
        pollTableView.allowsSelection = false
        pollTableView.isScrollEnabled = false
        pollTableView.delegate = self
        pollTableView.dataSource = self
        pollTableView.register(UINib(nibName: "PollCell", bundle: nil), forCellReuseIdentifier: "PollCell")
        return pollTableView
    }()
    
    let imagePicker = UIImagePickerController()
    var delegate: PostCreationDelegate?
    var postedImage: UIImage?
    var pod: PodList?
    var pollOptions = ["", ""]
    
    // MARK: - NewPostViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightBlue
        setupBackgroundView()
        setupPodHeader()
        setupTextField()
        setupButtons()
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tapGesture)
        imagePicker.delegate = self

        postPhotoButton.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(postPhoto))
        postPhotoButton.addGestureRecognizer(tapRecognizer)
        
        postPollButton.addTarget(self, action: #selector(postPoll(_:)), for: .touchUpInside)
    }
    
    func setupBackgroundView(){
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.textBackgroundView.frame
        rectShape.position = self.textBackgroundView.center
        rectShape.path = UIBezierPath(roundedRect: self.textBackgroundView.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 30, height: 30)).cgPath
        
        //Here I'm masking the textView's layer with rectShape layer
        self.textBackgroundView.layer.mask = rectShape
    }

    func setupPodHeader(){
        podTitle.font = UIFont.systemFont(ofSize: 20)
        podTitle.textColor = UIColor.white
        podTitle.text = "Sample Pod"
        cancelButton.setTitleColor(.white, for: .normal)
    }
    
    func setupTextField(){
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.placeholder = "Whats up?"
    }
    
    func setupButtons(){
        sendButton.backgroundColor = UIColor.lightBlue
        sendButton.layer.cornerRadius = 8
        sendButton.setTitleColor(UIColor.white, for: .normal)
        
        postPollButton.setBackgroundImage(UIImage(named: "add_poll_blue"), for: .selected)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //if self.textBackgroundView.frame.origin.y == 0{
               // self.textBackgroundView.frame.origin.y -= keyboardSize.height
            //}
            self.view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: self.view.frame.width, height: view.frame.height - keyboardSize.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.textBackgroundView.frame.origin.y != 0{
//                self.textBackgroundView.frame.origin.y += keyboardSize.height
//            }
            self.view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: self.view.frame.width, height: view.frame.height + keyboardSize.height)
        }
    }
    
    
    func tap(gesture: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    func postPoll(_ sender: UIButton) {
        postPollButton.isSelected = !postPollButton.isSelected
        if postPollButton.isSelected {
            view.addSubview(pollTableView.usingAutolayout())
//            let bottomConstraint = pollTableView.bottomAnchor.constraint(equalTo: postPollButton.topAnchor, constant: -10.0)
//            let bottomInequalityConstraint = pollTableView.bottomAnchor.constraint(greaterThanOrEqualTo: postPollButton.topAnchor, constant: -10.0)
//            bottomInequalityConstraint.priority = 1000
            NSLayoutConstraint.activate([
                pollTableView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 36.0),
                pollTableView.leftAnchor.constraint(equalTo: textView.leftAnchor),
                pollTableView.rightAnchor.constraint(equalTo: textView.rightAnchor),
                pollTableView.bottomAnchor.constraint(equalTo: postPollButton.topAnchor, constant: -10.0)
//                bottomConstraint,
//                bottomInequalityConstraint
                ])
        } else {
            pollOptions = ["", ""]
            pollTableView.removeFromSuperview()
            pollTableView.reloadData()
        }
        
    }
    
    func postPhoto(gesture: UITapGestureRecognizer) {
        self.postPhotoButton.image = UIImage(named: "add_photo_blue")
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.postPhotoButton.image = UIImage(named: "add_photo_gray")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelNewPost(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewPost(_ sender: UIButton) {
        if(pod?._userIdList?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
            createPost()
        } else {
            let alertController = UIAlertController(title: "Join Pod?", message: "To post to this pod you have to join first. Click 'Join' to join the conversation", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let DestructiveAction = UIAlertAction(title: "Leave", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                APIClient.sharedInstance.getPod(withId: Int((self.pod?._podId)!), geoHash: (self.pod?._geoHashCode)!, completion: { (pod_db) in
                    
                    let identityManager = AWSIdentityManager.default()
                    var userName: String?
                    if let identityUserName = identityManager.identityProfile?.userName {
                        userName = identityUserName
                    } else {
                        userName = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
                    }
                    self.pod?._userIdList?.append(FacebookIdentityProfile._sharedInstance.userId!)
                    pod_db?._userIdList?.append(FacebookIdentityProfile._sharedInstance.userId!)
                    pod_db?._usernameList?.append(userName!)
                    APIClient.sharedInstance.addPodToUsersList(podId: Int((self.pod?._podId)!), geoHash: (self.pod?._geoHashCode!)!)
                    APIClient.sharedInstance.updatePod(pod: pod_db!)
                    //APIClient.sharedInstance.removePossibleRequests(podId: self.pod?._podId as! Int)
                    self.createPost()
                    
                })
            }
            
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func createPost(){
        //First determine if there is an image
        var hasImage = false
        let range = NSRange(location: 0, length: textView.attributedText.length)
        if (textView.textStorage.containsAttachments(in: range)) {
            let attrString = textView.attributedText
            var location = 0
            while location < range.length {
                var r = NSRange()
                let attrDictionary = attrString?.attributes(at: location, effectiveRange: &r)
                if attrDictionary != nil {
                    // Swift.print(attrDictionary!)
                    let attachment = attrDictionary![NSAttachmentAttributeName] as? NSTextAttachment
                    if attachment != nil {
                        if attachment!.image != nil {
                            // your code to use attachment!.image as appropriate
                            hasImage = true
                        }
                    }
                    location += r.length
                }
            }
        }

        let post = Posts()
        post?._posterName = FacebookIdentityProfile._sharedInstance.userName!
        post?._posterImageURL = FacebookIdentityProfile._sharedInstance.imageURL?.absoluteString
        post?._podId = self.pod?._podId as NSNumber?
        post?._numComments = 0
        post?._postType = PostType.text.hashValue as NSNumber
        post?._postContent = textView.text
        post?._postedDate = NSDate().timeIntervalSince1970 as NSNumber
        post?._postId = UUID().uuidString
        //If it is a poll
        if postPollButton.isSelected {
            post?._postType = PostType.poll.hashValue as NSNumber
            post?._postImage = "No Image"
            post?._postPoll = [:]
            for cell in self.pollTableView.visibleCells.enumerated(){
                let c = cell.element as? PollCell
                if c?.inputField.text! != "" {
                    post?._postPoll?[(c?.inputField.text!)!] = ["init"]
                }
            }
            APIClient().createNewPostForPod(withId: Int((self.pod?._podId)!), post: post!)
            
            self.delegate?.postCreated(post: post!)
            self.dismiss(animated: true, completion: nil)
        // If it is an image
        } else if(hasImage){
            post?._postPoll = nil
            post?._postType = PostType.photo.hashValue as NSNumber
            //post?._postImage = postedImage
            let uuid = UUID().uuidString
            post?._postImage = "\(uuid).jpg"
           // postedImage = resize(image: postedImage!)
            let data = UIImagePNGRepresentation(postedImage!)
            let key = "\(uuid).jpg"
            
            post?.image = postedImage
            uploadWithData(data: data!, forKey: key) { () -> (AWSS3TransferUtilityUploadCompletionHandlerBlock?) in
                APIClient().createNewPostForPod(withId: Int((self.pod?._podId)!), post: post!)
                self.delegate?.postCreated(post: post!)
                self.dismiss(animated: true, completion: nil)
                return nil
            }
        //Else it is a text post
        } else {
            post?._postPoll = nil
            post?._postType = PostType.text.hashValue as NSNumber
            post?._postImage = "No Image"
            APIClient().createNewPostForPod(withId: Int((self.pod?._podId)!), post: post!)
            
            self.delegate?.postCreated(post: post!)
            self.dismiss(animated: true, completion: nil)
        }

        
    }
    
    func completionHandler() -> AWSS3TransferUtilityUploadCompletionHandlerBlock? {
        DispatchQueue.main.async {
            print("done")
        }
        return nil
    }
    
    fileprivate func uploadWithData(data: Data, forKey key: String, completion: @escaping ()->(AWSS3TransferUtilityUploadCompletionHandlerBlock?)) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
            print(progress.fractionCompleted)
        })
        }
        
        let  transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data,
                                   bucket: "pod-postphotos",
                                   key: key,
                                   contentType: "image/png",
                                   expression: expression,
                                   completionHandler: completion()).continueWith { (task) -> AnyObject! in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    if let _ = task.result {
                                        // Do something with uploadTask.
                                    }
                                    
                                    return nil;
        }
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

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // TODO: Send profile image to backend
        if let selectedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            let attributedString = NSMutableAttributedString(string: " \(textView.text!) \n")
            let textAttachment = NSTextAttachment()
            textAttachment.image = selectedImage
            let oldWidth = textAttachment.image!.size.width;
            
            let scaleFactor = oldWidth / (textView.frame.size.width - 10); //for the padding inside the textView
            if(imagePicker.sourceType == .camera){
                textAttachment.image = UIImage(cgImage: (textAttachment.image?.cgImage)!, scale: scaleFactor, orientation: UIImageOrientation.right)
            } else {
                textAttachment.image = UIImage(cgImage: (textAttachment.image?.cgImage)!, scale: scaleFactor, orientation: UIImageOrientation.up)
            }
            postedImage = textAttachment.image
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.append(attrStringWithImage)
           // attributedString.replaceCharacters(in: NSMakeRange(numChars-1, numChars-1), with: attrStringWithImage)
            textView.attributedText = attributedString;
            textView.placeholder = ""
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

// MARK: - UITableView Methods

extension NewPostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 41.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollCell
        cell.inputField.text = pollOptions[indexPath.row]
        cell.delegate = self
        if indexPath.row == pollOptions.count - 1 {
            cell.addButton.isHidden = false
        } else {
            cell.addButton.isHidden = true
        }
        return cell
    }
}

// MARK: - PollCell Methods

extension NewPostViewController: PollCellDelegate {
    func addNewOption(index: Int) {
        pollOptions.append("")
        pollTableView.reloadData()
    }
}

protocol PostCreationDelegate {
    func postCreated(post: Posts)
}

func resize(image: UIImage) -> UIImage{
    var actualHeight = image.size.height
    var actualWidth = image.size.width
    let maxHeight = 234.0 as CGFloat
    let maxWidth = 250.0 as CGFloat
    var imgRatio = actualWidth/actualHeight
    let maxRatio = maxWidth/maxHeight
    let compressionQuality = 0.90
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    let imgData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
    UIGraphicsEndImageContext()
    return UIImage(data: imgData!)!
}

