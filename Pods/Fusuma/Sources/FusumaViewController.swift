//
//  FusumaViewController.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


public protocol FusumaDelegate: class {
    // MARK: Required
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode)
    func fusumaVideoCompleted(withFileURL fileURL: URL)
    func fusumaCameraRollUnauthorized()
    
    // MARK: Optional
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode)
    func fusumaClosed()
}

extension FusumaDelegate {
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
    func fusumaClosed() {}
}

public var fusumaBaseTintColor   = UIColor.hex("#FFFFFF", alpha: 1.0)
public var fusumaTintColor       = UIColor.hex("#F38181", alpha: 1.0)
public var fusumaBackgroundColor = UIColor.hex("#3B3D45", alpha: 1.0)

public var fusumaAlbumImage : UIImage? = nil
public var fusumaCameraImage : UIImage? = nil
public var fusumaVideoImage : UIImage? = nil
public var fusumaCheckImage : UIImage? = nil
public var fusumaCloseImage : UIImage? = nil
public var fusumaFlashOnImage : UIImage? = nil
public var fusumaFlashOffImage : UIImage? = nil
public var fusumaFlipImage : UIImage? = nil
public var fusumaShotImage : UIImage? = nil

public var fusumaVideoStartImage : UIImage? = nil
public var fusumaVideoStopImage : UIImage? = nil

public var fusumaCropImage: Bool = true

public var fusumaCameraRollTitle = "CAMERA ROLL"
public var fusumaCameraTitle = "PHOTO"
public var fusumaVideoTitle = "VIDEO"
public var fusumaTitleFont = UIFont(name: "AvenirNext-DemiBold", size: 15)

public var fusumaTintIcons : Bool = true

public enum FusumaModeOrder {
    case cameraFirst
    case libraryFirst
}

public enum FusumaMode {
    case camera
    case library
    case video
}

//@objc public class FusumaViewController: UIViewController, FSCameraViewDelegate, FSAlbumViewDelegate {
public final class FusumaViewController: UIViewController {
    
    public var hasVideo = false
    public var cropHeightRatio: CGFloat = 1
    
    var mode: FusumaMode = .camera
    public var modeOrder: FusumaModeOrder = .cameraFirst
    var willFilter = true
    
    @IBOutlet public weak var cameraShotContainer: UIView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    
    lazy var albumView  = FSAlbumView.instance()
    lazy var cameraView = FSCameraView.instance()
    
    fileprivate var hasGalleryPermission: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public weak var delegate: FusumaDelegate? = nil
    
    override public func loadView() {
        
        if let view = UINib(nibName: "FusumaViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            
            self.view = view
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = fusumaBackgroundColor
        
        cameraView.delegate = self
        albumView.delegate  = self
        
        menuView.backgroundColor = fusumaBackgroundColor
        menuView.addBottomBorder(UIColor.black, width: 1.0)
        
        let bundle = Bundle(for: self.classForCoder)
        
        
        let checkImage = fusumaCheckImage != nil ? fusumaCheckImage : UIImage(named: "ic_check", in: bundle, compatibleWith: nil)
        let closeImage = fusumaCloseImage != nil ? fusumaCloseImage : UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        
        if fusumaTintIcons {
            
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            closeButton.tintColor = fusumaBaseTintColor
            
            doneButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            doneButton.tintColor = fusumaBaseTintColor
            
        } else {
            
            
            closeButton.setImage(closeImage, for: UIControlState())
            doneButton.setImage(checkImage, for: UIControlState())
        }
        
        cameraShotContainer.addSubview(cameraView)
        
        titleLabel.textColor = fusumaBaseTintColor
        titleLabel.font = fusumaTitleFont
        
        
        if fusumaCropImage {
            let heightRatio = getCropHeightRatio()
            
            cameraView.croppedAspectRatioConstraint = NSLayoutConstraint(item: cameraView.previewViewContainer, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: cameraView.previewViewContainer, attribute: NSLayoutAttribute.width, multiplier: heightRatio, constant: 0)
            
            cameraView.fullAspectRatioConstraint.isActive = false
            cameraView.croppedAspectRatioConstraint?.isActive = true
        } else {
            cameraView.fullAspectRatioConstraint.isActive = true
            cameraView.croppedAspectRatioConstraint?.isActive = false
        }
        
        changeMode(FusumaMode.camera)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        albumView.layoutIfNeeded()
        cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
        cameraView.layoutIfNeeded()
        
        
        albumView.initialize()
        cameraView.initialize()

    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAll()
    }
    
    override public var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            
            self.delegate?.fusumaClosed()
        })
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        
        changeMode(FusumaMode.library)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        
        changeMode(FusumaMode.camera)
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        
        changeMode(FusumaMode.video)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let view = albumView.imageCropView
        
        if fusumaCropImage {
            let normalizedX = (view?.contentOffset.x)! / (view?.contentSize.width)!
            let normalizedY = (view?.contentOffset.y)! / (view?.contentSize.height)!
            
            let normalizedWidth = (view?.frame.width)! / (view?.contentSize.width)!
            let normalizedHeight = (view?.frame.height)! / (view?.contentSize.height)!
            
            let cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
            
            DispatchQueue.global(qos: .default).async(execute: {
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.normalizedCropRect = cropRect
                options.resizeMode = .exact
                
                let targetWidth = floor(CGFloat(self.albumView.phAsset.pixelWidth) * cropRect.width)
                let targetHeight = floor(CGFloat(self.albumView.phAsset.pixelHeight) * cropRect.height)
                let dimensionW = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
                let dimensionH = dimensionW * self.getCropHeightRatio()
                
                let targetSize = CGSize(width: dimensionW, height: dimensionH)
                
                PHImageManager.default().requestImage(for: self.albumView.phAsset, targetSize: targetSize,
                                                      contentMode: .aspectFill, options: options) {
                                                        result, info in
                                                        
                                                        DispatchQueue.main.async(execute: {
                                                            self.delegate?.fusumaImageSelected(result!, source: self.mode)
                                                            
                                                            self.dismiss(animated: true, completion: {
                                                                self.delegate?.fusumaDismissedWithImage(result!, source: self.mode)
                                                            })
                                                        })
                }
            })
        } else {
            print("no image crop ")
            delegate?.fusumaImageSelected((view?.image)!, source: mode)
            
            self.dismiss(animated: true, completion: {
                self.delegate?.fusumaDismissedWithImage((view?.image)!, source: self.mode)
            })
        }
    }
    
}

extension FusumaViewController: FSAlbumViewDelegate, FSCameraViewDelegate, FSVideoCameraViewDelegate {
    public func getCropHeightRatio() -> CGFloat {
        return cropHeightRatio
    }
    
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        
        delegate?.fusumaImageSelected(image, source: mode)
        self.dismiss(animated: true, completion: {
            
            self.delegate?.fusumaDismissedWithImage(image, source: self.mode)
        })
    }
    
    public func albumViewCameraRollAuthorized() {
        // in the case that we're just coming back from granting photo gallery permissions
        // ensure the done button is visible if it should be
        self.updateDoneButtonVisibility()
    }
    
    // MARK: FSAlbumViewDelegate
    public func albumViewCameraRollUnauthorized() {
        delegate?.fusumaCameraRollUnauthorized()
    }
    
    func videoFinished(withFileURL fileURL: URL) {
        delegate?.fusumaVideoCompleted(withFileURL: fileURL)
        self.dismiss(animated: true, completion: nil)
    }
    
}

private extension FusumaViewController {
    
    func stopAll() {
        
        self.cameraView.stopCamera()
    }
    
    func changeMode(_ mode: FusumaMode) {
        
        if self.mode == mode {
            return
        }
        
        //operate this switch before changing mode to stop cameras
        switch self.mode {
        case .library:
            break
        case .camera:
            self.cameraView.stopCamera()
        case .video:
            break
        }
        
        self.mode = mode
        
        dishighlightButtons()
        updateDoneButtonVisibility()
        
        switch mode {
        case .library:
            titleLabel.text = NSLocalizedString(fusumaCameraRollTitle, comment: fusumaCameraRollTitle)
            
        case .camera:
            titleLabel.text = NSLocalizedString(fusumaCameraTitle, comment: fusumaCameraTitle)
            
            self.view.bringSubview(toFront: cameraShotContainer)
            cameraView.startCamera()
        case .video:
            break
        }
        doneButton.isHidden = !hasGalleryPermission
        self.view.bringSubview(toFront: menuView)
    }
    
    
    func updateDoneButtonVisibility() {
        // don't show the done button without gallery permission
        if !hasGalleryPermission {
            self.doneButton.isHidden = true
            return
        }
        
        switch self.mode {
        case .library:
            self.doneButton.isHidden = false
        default:
            self.doneButton.isHidden = true
        }
    }
    
    func dishighlightButtons() {
        
    }
    
    func highlightButton(_ button: UIButton) {
        
        button.tintColor = fusumaTintColor
        
        button.addBottomBorder(fusumaTintColor, width: 3)
    }
}
