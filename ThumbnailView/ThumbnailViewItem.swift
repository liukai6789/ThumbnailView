//
//  ThumbnailViewItem.swift
//  imagePicker
//
//  Created by Gis on 2018/7/30.
//  Copyright © 2018年 Gis. All rights reserved.
//

import UIKit

open class ThumbnailViewItem: UIView {}

/// 一个简单的ThumbnailViewItem，显示一张图片
public class SimpleThumbnailViewItem: ThumbnailViewItem {

    private let imgView = UIImageView()

    public convenience init(image: UIImage?) {

        self.init(frame: CGRect())
        imgView.image = image
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        imgView.clipsToBounds = true
        self.addSubview(imgView)

    }

    override public func layoutSubviews() {

        super.layoutSubviews()
        imgView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)

    }

}
