//
//  ViewController.swift
//  Meme Me 1.0
//
//  Created by Sarah Hernandez on 4/14/18.
//  Copyright © 2018 Sarah Hernandez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var didBeginEditingTop = false
    var didBeginEditingBottom = false
    var didSelectImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        let memeTextAttributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
            NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue : -5,
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = NSTextAlignment.center
        bottomTextField.textAlignment = NSTextAlignment.center
        topTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        bottomTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    
        topTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.adjustsFontSizeToFitWidth = true
        
        //Disables share button upon start up. Will be enabled once image chosen
        shareButton.isEnabled = false
    }
    
    // Clears text if user is editing it for the first time, prevents deletion of user-entered text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if !didBeginEditingTop{
            
            topTextField.text = ""
            didBeginEditingTop = true
            
        }else if !didBeginEditingBottom{
            
            bottomTextField.text = ""
            didBeginEditingBottom = true
        }
        
        
        
    }
    
    // Stops editing text field when user presses Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    // View Will Appear: includes call to Subscribe to Keyboard Notifications
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // Disables camera if no camera is avaialable
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

    }
   
    // Subscribe to Keyboard Notifications
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
   
    // Shift the view's frame up when Keyboard Notification is received
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if bottomTextField.isEditing{
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    // Shift keyboard back down:
    @objc func keyboardWillHide(_ notification: Notification){
        
        view.frame.origin.y = 0
    }
    // Gets keybaord height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // View Will Disapear: includes call to Unsubscribe to Keyboard Notifications
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Unsubscribe to Keyboard Notifications
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: User takes picture with camera
    @IBAction func takeAPicture(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    // MARK: user picks picture from photo library
    @IBAction func pickAPicture(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    //Called when user picks an image:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        //Sets image
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageView.image = image
            didSelectImage = true
            
            shareButton.isEnabled = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Called when user cancels out of the image picker view
    func imagePickerControllerDidCancel(_: UIImagePickerController){
        
        self.dismiss(animated: true, completion: nil)
        
    }

    // MARK: Start process of saving an image:
    struct Meme {
        let topText : String
        let bottomText : String
        let originalImage : UIImage
        let memedImage : UIImage
    }
    
    func getMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        navBar.isHidden = true
        toolBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        navBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
        
    }
    
    func save() {
        // creates and saves meme:
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: getMemedImage())
    }
    
    // Share an image:
    @IBAction func shareMeme(_ sender: Any) {
        
        let finalMemeImage = getMemedImage()
        let controller = UIActivityViewController(activityItems: [finalMemeImage], applicationActivities: nil)
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            
            // Checks if user canceled the share action, and skips saving if so
            if activityType != nil{
                self.save()
            }
            
            self.dismiss(animated: true, completion: nil)

        }
        present(controller, animated: true, completion: nil)
        
    }
    
}













