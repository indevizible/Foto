//
//  PlayViewController.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/23/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    weak var photoAlbum: PhotoAlbum?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoAlbum = photoAlbum {
            
            OperationQueue.current?.addOperation{
                let imgs = photoAlbum.fetchImages()?.map { $0.image(size: self.imageView.frame.size) } ?? [#imageLiteral(resourceName: "no-image")]
                self.imageView.animationImages = imgs
                
                OperationQueue.main.addOperation {
                    self.slider.maximumValue = Float(imgs.count) / 0.6
                    self.slider.value = self.slider.maximumValue / 2
                    self.imageView.animationDuration = TimeInterval(self.slider.value)
                    self.imageView.startAnimating()
                }
            }
            
            
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func sliding(_ sender: UISlider) {
        imageView.animationDuration = TimeInterval(slider.value)
        imageView.startAnimating()
    }

}
