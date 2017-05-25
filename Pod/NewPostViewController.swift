//
//  NewPostViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {

    @IBOutlet weak var textBackgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var postPhotoButton: UIImageView!
    
    let imagePicker = UIImagePickerController()

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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    func postPhoto(gesture: UITapGestureRecognizer) {

        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
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
        dismiss(animated: true, completion: nil)
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
            let attributedString = NSMutableAttributedString(string: "")
            let textAttachment = NSTextAttachment()
            textAttachment.image = selectedImage
            let oldWidth = textAttachment.image!.size.width;
            
            let scaleFactor = oldWidth / (textView.frame.size.width - 10); //for the padding inside the textView
            if(imagePicker.sourceType == .camera){
                textAttachment.image = UIImage(cgImage: (textAttachment.image?.cgImage)!, scale: scaleFactor, orientation: UIImageOrientation.right)
            } else {
                textAttachment.image = UIImage(cgImage: (textAttachment.image?.cgImage)!, scale: scaleFactor, orientation: UIImageOrientation.up)
            }
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharacters(in: NSMakeRange(0, 0), with: attrStringWithImage)
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
