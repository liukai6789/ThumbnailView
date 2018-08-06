//
//  ThumbnailViewDelegate.swift
//  imagePicker
//
//  Created by Gis on 2018/7/30.
//  Copyright © 2018年 Gis. All rights reserved.
//

import UIKit

@objc public protocol ThumbnailViewDelegate {

    /// 显示的item个数
    func numberOfItems(thumbnailView: ThumbnailView) -> Int

    /// 对应的ThumbnailViewItem
    func thumbnailView(thumbnailView: ThumbnailView, itemFor index: Int) -> ThumbnailViewItem

    /// optional，点击item
    @objc optional func thumbnailView(thumbnailView: ThumbnailView, didSelectItemAt index: Int) -> Void

    /// optional，点击增加item
    @objc optional func didAddItem(thumbnailView: ThumbnailView) -> Void

}
