//
//  Photos.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/22/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import Photos

class PhotoAlbum {
    
    let albumName: String
    
    var assetCollection: PHAssetCollection!
    
    init(name albumName: String) {
        
        self.albumName = albumName
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject!
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
                
            }
        }
        
    }
    
    func save(image: UIImage) {
        
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { success, err in
            
        })
    }
    
    func save(image: UIImage,callback: @escaping (Bool) -> Void) {
        guard assetCollection != nil else {
            callback(false)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { success, err in
            callback(success)
        })
    }
    
    func fetchImages() -> [PHAsset]? {
        guard assetCollection != nil else {
            return nil
        }
        
        let option = PHFetchOptions()
        option.predicate = NSPredicate(format: "title = %@", albumName)
        guard let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: option).firstObject else {
            return nil
        }
        let collectionResult = PHAsset.fetchAssets(in: collection, options: nil)
        var a = [PHAsset]()
        collectionResult.enumerateObjects({ (asset, idx, stop) in
            a.append(asset)
        })
        
        return a
    }
    
    static func thumbsForAlbums(albums: [String], size: CGSize) -> [UIImage] {
        return albums.map { name -> UIImage in
            let album = PhotoAlbum(name: name)
            if let img = album.fetchImages()?.last {
                return img.image(size: size)
            }else{
                return #imageLiteral(resourceName: "no-image")
            }
        }
    }
    
}

extension PHAsset {
    
    func image(size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }
}
