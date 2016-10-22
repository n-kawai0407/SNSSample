//
//  ViewController.swift
//  SNSSample
//
//  Created by MasaKentaro on 2016/08/10.
//  Copyright © 2016年 MasaKentaro. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func cameraButtonTapped(sender: AnyObject) {
        
        let sourceType:UIImagePickerControllerSourceType = .camera
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = sourceType
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            label.text = "カメラは使用できません"
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
        
        if picker.sourceType == .camera {
            label.text = "撮影を完了しました"
        } else {
            label.text = "画像データを読み込みました"
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if picker.sourceType == .camera {
            label.text = "撮影をキャンセルしました"
        } else {
            label.text = "画像データの読み込みをキャンセルしました"
        }
    }
    
    
    @IBAction func saveButtonTapped(sender : AnyObject) {
        guard let image = imageView.image else {
            label.text = "imageView.imageが空です"
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(ViewController.image(
                image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!,
               contextInfo: UnsafeMutableRawPointer) {
        
        if error != nil {
            label.text = "画像データを保存できませんでした"
        } else {
            label.text = "画像データを保存しました"
        }
    }
    
    @IBAction func selectionButtonTapped(sender : AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            label.text = "フォトライブラリは使用できません"
        }
    }
    
    @IBAction func otherButtonTapped(sender : AnyObject) {
        
        let actionController:UIAlertController =
            UIAlertController(title:"メニュー",
                              message: nil,
                              preferredStyle: .actionSheet)
        
        let twitterAction:UIAlertAction =
            UIAlertAction(title: "Twitter",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.label.text = "Twitterを選択しました"
                            self.post(serviceType: SLServiceTypeTwitter)})
        
        let facebookAction:UIAlertAction =
            UIAlertAction(title: "Facebook",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.label.text = "Facebookを選択しました"
                            self.post(serviceType: SLServiceTypeFacebook)})
        
        let faceDetectionAction:UIAlertAction =
            UIAlertAction(title: "顔認識",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.label.text = "顔認識を選択しました"
                            self.detect()})
        
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "キャンセル",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.label.text = "キャンセルしました"})
        
        actionController.addAction(twitterAction)
        actionController.addAction(facebookAction)
        actionController.addAction(faceDetectionAction)
        actionController.addAction(cancelAction)
        
        present(actionController, animated: true, completion: nil)
    }
    
    func post(serviceType : String) {
        let composer:SLComposeViewController =
            SLComposeViewController(forServiceType: serviceType)!
        composer.add(imageView.image)
        composer.completionHandler = {
            (result:SLComposeViewControllerResult) in
            
            switch result {
            case .done:
                self.label.text = "投稿しました"
            case .cancelled:
                self.label.text = "投稿をキャンセルしました"
            }
        }
        
        self.present(composer, animated: true, completion: nil)
    }
    
    func detect() {
        guard let image = imageView.image else {
            label.text = "imageView.imageが空です"
            return
        }
        
        if let cgImage = image.cgImage {
            let ciImage = CIImage(cgImage:cgImage)
            let detector = CIDetector(ofType: CIDetectorTypeFace,
                                      context: nil,
                                      options: nil)
            let features = detector?.features(in: ciImage)
            
            UIGraphicsBeginImageContext(image.size)
            image.draw(in: CGRect(x: 0,
                                  y: 0,
                                  width: image.size.width,
                                  height: image.size.height))
            
            if let features = features {
                features.forEach { feature in
                    var faceBounds = (feature as! CIFaceFeature).bounds
                    faceBounds.origin.y = ( image.size.height -
                        faceBounds.origin.y - faceBounds.size.height )
                    
                    if let context = UIGraphicsGetCurrentContext() {
                        context.setStrokeColor(UIColor.red.cgColor)
                        context.setLineWidth(5.0)
                        context.stroke(faceBounds)
                    }
                }
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                imageView.image = newImage
            }
        }
    }
}

