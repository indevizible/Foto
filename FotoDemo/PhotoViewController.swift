//
//  PhotoViewController.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/23/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import UIKit
import Photos
import Fusuma

class PhotoViewController: UITableViewController {
    
    lazy var dateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd hh:mm:ss"
        return df
    }()
    
    var photoAlbum: PhotoAlbum?
    
    var photo: [PHAsset]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo = photoAlbum?.fetchImages()
        
        tableViewScrollToBottom(animated: true)

    }
    

    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return photo?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let p = photo?[indexPath.row] {
            cell.imageView?.image = p.image(size: CGSize(all: 55).screenSize())
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.clipsToBounds = true
            
            if let date = p.creationDate {
                cell.textLabel?.text = dateFormatter.string(from: date)
            }else{
                cell.textLabel?.text = nil
            }
        }

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            OperationQueue.current?.addOperation {
                if let asset = self.photo?[indexPath.row] {
                    let assets = NSArray(array: [asset])
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.deleteAssets(assets)
                    }, completionHandler: { (success, error) in
                        OperationQueue.main.addOperation {
                            if success {
                                self.photo?.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }else{
                                tableView.setEditing(false, animated: true)
                            }
                        }
                    })
                }
            }
        }
    }
    
    var fusuma: FusumaViewController!
    @IBAction func camera(_ sender: UIBarButtonItem) {
        fusuma = FusumaViewController()
        fusuma.delegate = self
        present(fusuma, animated: true, completion: nil)
        let size = CGSize(all: UIScreen.main.bounds.width)
        if let p = photo?.last?.image(size: size.screenSize()) {
            let imageView = UIImageView(image: p)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = CGRect(origin: CGPoint(x: 0, y: 50), size: size)
            imageView.alpha = 0.4
            fusuma.cameraShotContainer.addSubview(imageView)
        }
        
    }

    // Override to support rearranging the table view.


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? PlayViewController {
            destination.photoAlbum = photoAlbum
        }
    }
    

}

extension PhotoViewController: FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        OperationQueue.current?.addOperation {
            self.photoAlbum?.save(image: image) { success in
                if success {
                    self.photo = self.photoAlbum?.fetchImages()
                    OperationQueue.main.addOperation {
                        let indexPath = IndexPath(item: self.photo!.count - 1, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .automatic)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
        
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

