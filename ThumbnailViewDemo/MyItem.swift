//
//  MyItem.swift
//  imagePicker
//
//  Created by Gis on 2018/7/31.
//  Copyright © 2018年 Gis. All rights reserved.
//

import UIKit

class MyItem: ThumbnailViewItem {

    var deleteClosure: (() -> Void)?


    @IBAction func deleteAction(_ sender: Any) {
        deleteClosure?()
    }
}
