//
//  Helper.swift
//  FotoDemo
//
//  Created by Nattawut Singhchai on 12/23/16.
//  Copyright © 2016 Nattawut Singhchai. All rights reserved.
//

import UIKit

extension CGSize {
    func screenSize() -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: width * scale, height: height * scale)
    }
    
    init(all: CGFloat) {
        self =  CGSize(width: all, height: all)
    }
}
