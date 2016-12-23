//
//  AlbumViewController.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/22/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import UIKit

class AlbumViewController: UITableViewController {
    
    lazy var dateFormatter = { () -> DateFormatter in 
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var albums: [String]! {
        didSet {
            photoAlbums = albums.map { PhotoAlbum(name: $0) }
            images = photoAlbums.map { album in
                let img = album.fetchImages()
                let a = img?.last?.image(size: CGSize(width: 110, height: 110)) ?? #imageLiteral(resourceName: "no-image")
                let b = img?.last?.creationDate!
                
                return (a,b)
            }
            
            UserDefaults.standard.set(albums, forKey: "Albums")
            
        }
    }
    
    var photoAlbums: [PhotoAlbum]!
    var images: [(image: UIImage, createDate: Date?)]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        albums = fetchAlbumList()
        
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        
        cell.imageView?.image = images[indexPath.row].image
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        if let date = images[indexPath.row].createDate {
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        }else{
            cell.detailTextLabel?.text = nil
        }
        
        cell.textLabel?.text = albums[indexPath.row]

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
            var tmp = albums!
            tmp.remove(at: indexPath.row)
            albums = tmp
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var tmp = albums!
        let str = tmp.remove(at: fromIndexPath.row)
        tmp.insert(str, at: to.row)
        albums = tmp
        
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        if let destination = segue.destination as? PhotoViewController,
            let indexPath = indexPath {
            destination.title = albums[indexPath.row]
            destination.photoAlbum = photoAlbums[indexPath.row]
        }
    }
    
    
    func fetchAlbumList() -> [String] {
        guard let obj = UserDefaults.standard.object(forKey: "Albums") else {
            return []
        }
        if let o = obj as? [String] {
            return o
        }else{
            return []
        }
    }
    
    @IBAction func addNewAlbum(_ sender: Any) {
        let alertController = UIAlertController(title: "New Album", message: nil, preferredStyle: .alert)
        var tf: UITextField!
        alertController.addTextField { (textFild) in
            tf = textFild
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            if let name = tf.text {
                var tmp = self.albums!
                tmp.append(name)
                self.albums = tmp
                let indexPath = IndexPath(item: self.albums.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }))
        present(alertController, animated: true, completion: nil)
        
    }


}
