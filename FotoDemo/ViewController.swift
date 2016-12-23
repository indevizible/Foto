//
//  ViewController.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/22/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import UIKit
import Fusuma
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var sampleImageView: UIImageView!
    var fusuma: FusumaViewController!
    
    let album = PhotoAlbum(name: "AK-47 🌱")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sampleImageView.image = #imageLiteral(resourceName: "img")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fusuma = FusumaViewController()
        
        fusuma.delegate = self
        fusuma.modeOrder = .cameraFirst
        //fusuma.hasVideo = true // If you want to let the users allow to use video.
        self.present(fusuma, animated: true, completion: nil)
        
        if let images = album.fetchImages() {
            
            if let image = images.last {
                
                let actualSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                let imageView = UIImageView(image: image.image(size: actualSize))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(origin: CGPoint(x: 0, y: 50), size: actualSize)
                imageView.alpha = 0.4
                fusuma.cameraShotContainer.addSubview(imageView)
            }
        }
        
    }

}

extension ViewController: FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        album.save(image: image)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        
    }
    
    func fusumaClosed() {
        
    }
}

