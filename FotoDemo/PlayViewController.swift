//
//  PlayViewController.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/23/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import UIKit
import Photos

class PlayViewController: UIViewController {

    weak var photoAlbum: PhotoAlbum?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoAlbum = photoAlbum {
            
            OperationQueue.current?.addOperation{
                let imgs = photoAlbum.fetchImages()?.map { $0.image(size: self.imageView.frame.size.screenSize()) } ?? [#imageLiteral(resourceName: "no-image")]
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
    

    @IBAction func exportToGif(_ sender: UIButton) {
        let size = CGSize(all: 256)
        let fetchedImages = photoAlbum?.fetchImages()
        let images = fetchedImages?.map { $0.image(size: size) }
        
        if let imgs = images, let libUrl = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).first {
            let finalURL = libUrl.appendingPathComponent("x.gif")
            
            do {
                try FileManager.default.removeItem(at: finalURL)
            }catch{
                
            }
            GifGenerator().generateGifFromImages(imagesArray: imgs, frameDelay: 0.3, destinationURL: finalURL, callback: { (data, error) in
                
                
                if error == nil {
                    _ = PhotoAlbum(name: "Foto Demo") { success, album in
                        album.save(URL: finalURL) { success in
                            if success {
                                let alertController  = UIAlertController(title: "Successful", message: "Gif saved in your camera roll", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                OperationQueue.main.addOperation {
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }else{
                                print("Cannot save")
                            }
                            
                            do {
                                try FileManager.default.removeItem(at: finalURL)
                            }catch{
                                print("can not remove")
                            }
                        }
                    }

                }else{
                    print(error!)
                }
            })
        }

    }
    
    
    @IBAction func sliding(_ sender: UISlider) {
        imageView.animationDuration = TimeInterval(slider.value)
        imageView.startAnimating()
    }

}
