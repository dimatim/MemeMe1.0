//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Timofti, Dmitri on 13/01/2017.
//  Copyright © 2017 Timofti, Dmitri. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            pickAnImage(source: .camera)
        case 1:
            pickAnImage(source: .photoLibrary)
        default:
            pickAnImage(source: .photoLibrary)
        }
    }
    
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: enableShare)
        
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        if (imageView.image != nil
            && topTextField.text != nil
            && bottomTextField.text != nil) {
            let meme = generateMemedImage()
            let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
            controller.completionWithItemsHandler = {(activity, completed, items, error) in
                if (completed) {
                    let _ = self.save()
                }
            }
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func enableShare() {
        shareButton.isEnabled = true
    }
    
    @IBAction func cancel(_ sender: Any) {
        imageView.image = nil
        topTextField.text = ""
        bottomTextField.text = ""
        shareButton.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        imageView.contentMode = UIViewContentMode.scaleAspectFit;
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        setTextAttributes(textField: topTextField)
        setTextAttributes(textField: bottomTextField)
    }
    
    func setTextAttributes(textField: UITextField) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0]
        textField.defaultTextAttributes = memeTextAttributes
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        showBars(show: false)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        showBars(show: true)
        
        return memedImage
    }
    
    func showBars(show: Bool) {
        navBar.isHidden = !show
        toolBar.isHidden = !show
    }
    
    func save() {
        // Create the meme
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())//TODO why is this needed?
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func keyboardWillShow(_ notification:Notification) {
        if !topTextField.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

}

