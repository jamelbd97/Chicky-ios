//
//  Camera.swift
//  Chicky
//
//  Created by Mac2021 on 15/11/2021.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import AVFoundation
import AVKit
import Alamofire

class CreateView: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // VAR
    private var pickerController: UIImagePickerController = UIImagePickerController()
    
    var videoUrl : URL?
    
    // WIDGET
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageViewPlaceholder: UIImageView!
    
    // PROTOCOLS
    
    // LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi")
        videoView.layer.cornerRadius = ROUNDED_RADIUS
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.movie"]
        self.pickerController.videoQuality = .typeHigh
    }
    
    // METHODS
    
    // ACTIONS
    @IBAction func ajouterPublication(_ sender: Any) {
        
        if (videoUrl == nil){
            self.present(Alert.makeAlert(titre: "Warning", message: "Choose a video"), animated: true)
            return
        }
        
        let publication = Publication( description: descriptionTextField.text, date: Date(), commentaires: [])
        PublicationViewModel().ajouterPublication(publication: publication, videoUrl: videoUrl!) { success in
            if success {
                self.present(Alert.makeAlert(titre: "Success", message: "Post added"),animated: true)
                self.present(Alert.makeSingleActionAlert(titre: "Success", message: "Post added", action: UIAlertAction(title: "Ok", style: .default, handler: { [self] UIAlertAction in
                    
                    videoView.layer.sublayers?.removeAll()
                    videoUrl = nil
                    descriptionTextField.text = ""
                    //self.tabBarController!.selectedIndex = 0
                })), animated: true)
            }
        }

    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.present(self.pickerController, animated: true)
        }
    }
    
    @IBAction func changePhoto(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Alert message.", preferredStyle: .actionSheet)

        let defaultAction = UIAlertAction(title: "Default", style: .default, handler: { (alert: UIAlertAction!) -> Void in
          //  Do some action here.
        })

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
          //  Do some destructive action here.
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
          //  Do something here upon cancellation.
        })

        alertController.addAction(defaultAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
          popoverController.barButtonItem = sender as? UIBarButtonItem
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func pickerController(_ controller: UIImagePickerController, didSelect url: URL?) {
        controller.dismiss(animated: true, completion: nil)

        if url == nil {
            return
        }
        
        imageViewPlaceholder.isHidden = true
        let player = AVPlayer(url: url!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        playerLayer.frame = videoView.bounds
        playerLayer.cornerRadius = ROUNDED_RADIUS
        playerLayer.masksToBounds = true
        videoView.layer.addSublayer(playerLayer)
        player.play()
        
        videoUrl = url
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        guard let url = info[.mediaURL] as? URL else {
            return self.pickerController(picker, didSelect: nil)
        }

//        //uncomment this if you want to save the video file to the media library
//        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
//            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
//        }
        self.pickerController(picker, didSelect: url)
    }
}
