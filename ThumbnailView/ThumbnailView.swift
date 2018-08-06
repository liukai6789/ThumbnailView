//
//  ThumbnailView.swift
//  imagePicker
//
//  Created by Gis on 2018/7/26.
//  Copyright © 2018年 Gis. All rights reserved.
//

import UIKit

/// 一个能自适应高度，显示多个thumbnail的控件。如果约束了高度，超过高度会显示滚动条。
///
/// 在xib中，由于系统控件(比如UILable,UIButton)可以直接使用Intrinsic Size - Default (System Defined)，
/// 但是自定义视图，如果你没有约束控件宽和高，需要选择Placeholder，里面的宽高可以先随便设置，只是先保证xib中的相对布局不报错

public class ThumbnailView: UIScrollView {

    public weak var thumbnailDelegate: ThumbnailViewDelegate?

    /// 能显示的最大数量，默认为5
    public var maxCount   = 5

    /// thumbnail的大小，默认为（60，60）
    public var itemSize   = CGSize.init(width: 60, height: 60);

    /// 边距，默认为UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    /// 如果allowEdgeInsetEqualToSpace为ture，edgeInsets.left和edgeInsets.right大小会调整，和minSpace.width一致
    public var edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    /// 最小间距：width表示水平方向，height表示垂直方向，默认为（10，10）
    /// 如果allowEdgeInsetEqualToSpace为ture，minSpace.width会调整，和edgeInsets.left,edgeInsets.right一致
    public var minSpace   = CGSize.init(width: 10, height: 10);

    /// 是否容许调整左右边距和间距，使两者大小一致，默认为true
    public var allowEdgeInsetEqualToSpace = true

    /// 增加按钮图片，如果没有使用默认图片
    public var addImage: UIImage?

    private var thumbnailItemCount = 0 /// 已经显示的item个数
    private let baseTag = 10000 //内部使用，用来记录各个控件的tag

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    /// 刷新控件
    public func reloadData() -> Void {
        self.setNeedsDisplay()
    }

}

extension ThumbnailView {

    private func commonInit() -> Void {

        self.backgroundColor = UIColor.white
        self.bounces = false

    }

    override public var intrinsicContentSize: CGSize {
        let size = self.contentSize
        if size.width == 0 || size.height == 0 {
            return CGSize(width: self.edgeInsets.left + self.itemSize.width + self.edgeInsets.right,
                          height: self.edgeInsets.top + self.itemSize.height + self.edgeInsets.bottom)
        }

        return size
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        /// 清除子view，重新渲染
        var subViews = self.subviews
        for (_, subView) in subviews.enumerated().filter({ (_, subView) in return subView.tag >= baseTag}) {
            subView .removeFromSuperview()
        }

        if thumbnailDelegate == nil {
            fatalError("The parameter of thumbnailDelegate must not be nil")
        }
        if maxCount < 0 {
            fatalError("maxCount must >= 0")
        }

        /// 获取要显示的item个数
        thumbnailItemCount = thumbnailDelegate!.numberOfItems(thumbnailView: self)
        thumbnailItemCount = thumbnailItemCount > maxCount ? maxCount : thumbnailItemCount
        if thumbnailItemCount < 0 {
            fatalError("The return value of numberOfItems(thumbnailView:) must >= 0")
        }


        /// 每行能显示的item个数
        func countByRow() -> Int {

            let size = self.bounds.size
            let count: Int = Int((size.width - edgeInsets.left - edgeInsets.right + minSpace.width) /
                (itemSize.width + minSpace.width))
            return count < 1 ? 1 : count

        }

        let count = countByRow()

        /// 是否需要调整minSpace和edgeInsets，确保左右边距和间距一致
        if allowEdgeInsetEqualToSpace {

            let size = self.bounds.size
            let newSpacef = (size.width - itemSize.width * CGFloat(count)) / CGFloat(count + 1)
            let newSpace = Int(newSpacef)
            self.minSpace = CGSize(width: CGFloat(newSpace),
                                   height: self.minSpace.height)
            self.edgeInsets = UIEdgeInsets(top: self.edgeInsets.top,
                                           left: CGFloat(newSpace),
                                           bottom: self.edgeInsets.bottom,
                                           right: CGFloat(newSpace))

        }

        /// 开始渲染子控件
        var previousItem: UIView? //上一个子控件
        var confirmSizeH = false // self.contentSize右边距是否已经确定

        for index in 0..<thumbnailItemCount {

            let item = thumbnailDelegate!.thumbnailView(thumbnailView: self, itemFor: index)
            self.addSubview(item)
            item.clipsToBounds = true
            item.tag = baseTag + index
            let ges = UITapGestureRecognizer(target: self,
                                             action: #selector(tapItemGestureRecognizer(gesture:)))
            item.addGestureRecognizer(ges)

            item.translatesAutoresizingMaskIntoConstraints = false
            if let previousItem = previousItem {
                if index % count == 0 {
                    /// 换行

                    /// 确定self.contentSize右边距的大小
                    if confirmSizeH == false {
                        confirmSizeH = true
                        self.addConstraints(
                            constraints(vf: "H:[previousItem]-space-|",
                                        options: .directionLeadingToTrailing,
                                        metrics: ["space": edgeInsets.right],
                                        views: ["previousItem": previousItem]))
                    }

                    self.addConstraints(
                        constraints(vf: "H:|-leftSpace-[item(width)]",
                                    options: .directionLeadingToTrailing,
                                    metrics: ["leftSpace": edgeInsets.left, "width": itemSize.width],
                                    views: ["item": item]) +
                        constraints(vf: "V:[previousItem]-space-[item(previousItem)]",
                                    options: .directionLeadingToTrailing,
                                    metrics: ["space": minSpace.height],
                                    views: ["item": item, "previousItem": previousItem]))
                } else {
                    /// 未换行
                    self.addConstraints(
                        constraints(vf: "H:[previousItem]-space-[item(previousItem)]",
                                    options: .alignAllTop,
                                    metrics: ["space": minSpace.width],
                                    views: ["item": item, "previousItem": previousItem]) +
                        constraints(vf: "V:[item(previousItem)]",
                                    options: .directionLeadingToTrailing,
                                    metrics: nil,
                                    views: ["item": item, "previousItem": previousItem]))
                }
            } else {
                /// 第一个item
                self.addConstraints(
                    constraints(vf: "H:|-leftSpace-[item(width)]",
                                options: .directionLeadingToTrailing,
                                metrics: ["leftSpace": edgeInsets.left, "width": itemSize.width],
                                views: ["item": item]) +
                    constraints(vf: "V:|-topSpace-[item(height)]",
                                options: .directionLeadingToTrailing,
                                metrics: ["topSpace": edgeInsets.top, "height": itemSize.height],
                                views: ["item": item]))
            }

            previousItem = item
        }

        if thumbnailItemCount < maxCount {
            /// 添加addImgView

            let addImgView: UIImageView
            if let addImage = addImage {
                addImgView = UIImageView(image: addImage)
            } else {
                let image = UIImage(named: "image.bundle/add",
                                    in: Bundle.init(for: type(of: self)),
                                    compatibleWith: nil)
                addImgView = UIImageView(image: image)
            }

            self.addSubview(addImgView)
            addImgView.tag = baseTag + thumbnailItemCount
            addImgView.isUserInteractionEnabled = true
            addImgView.contentMode = UIViewContentMode.scaleAspectFill
            addImgView.clipsToBounds = true
            let ges = UITapGestureRecognizer.init(target: self,
                                                  action: #selector(addItemGestureRecognizer))
            addImgView.addGestureRecognizer(ges)

            addImgView.translatesAutoresizingMaskIntoConstraints = false
            if thumbnailItemCount == 0 {
                /// 没有item
                self.addConstraints(
                    constraints(vf: "H:|-leftSpace-[addImgView(width)]",
                                options: .directionLeadingToTrailing,
                                metrics: ["leftSpace": edgeInsets.left, "width": itemSize.width],
                                views: ["addImgView": addImgView]) +
                    constraints(vf: "V:|-topSpace-[addImgView(height)]",
                                options: .directionLeadingToTrailing,
                                metrics: ["topSpace": edgeInsets.top, "height": itemSize.height],
                                views: ["addImgView": addImgView]))
            } else {
                if thumbnailItemCount % count == 0 {
                    /// 换行
                    self.addConstraints(
                        constraints(vf: "H:|-leftSpace-[addImgView(width)]",
                                    options: .directionLeadingToTrailing,
                                    metrics: ["leftSpace": edgeInsets.left, "width": itemSize.width],
                                    views: ["addImgView": addImgView]) +
                        constraints(vf: "V:[previousItem]-space-[addImgView(previousItem)]",
                                    options: .directionLeadingToTrailing,
                                    metrics: ["space": minSpace.height],
                                    views: ["addImgView": addImgView, "previousItem": previousItem!]))

                } else {
                    self.addConstraints(
                        constraints(vf: "H:[previousItem]-space-[addImgView(previousItem)]",
                                    options: .alignAllTop,
                                    metrics: ["space": minSpace.width],
                                    views: ["addImgView": addImgView, "previousItem": previousItem!]) +
                        constraints(vf: "V:[addImgView(previousItem)]",
                                    options: .directionLeadingToTrailing,
                                    metrics: nil,
                                    views: ["addImgView": addImgView, "previousItem": previousItem!]))
                }
            }

            previousItem = addImgView
        }

        /// 确定self.contentSize的下边距，和右边距（如果之前没有确定）
        if let previousItem = previousItem {
            if confirmSizeH == false {
                confirmSizeH = true

                self.addConstraints(
                    constraints(vf: "H:[previousItem]-space-|",
                                options: .directionLeadingToTrailing,
                                metrics: ["space": edgeInsets.right],
                                views: ["previousItem": previousItem]))
            }

            self.addConstraints(
                constraints(vf: "V:[previousItem]-space-|",
                            options: .directionLeadingToTrailing,
                            metrics: ["space": edgeInsets.bottom],
                            views: ["previousItem": previousItem]))
        }


        /// 异步重新计算intrinsicContentSize：要确保self的contentSize自动计算完毕之后
        DispatchQueue.main.async {
            self.invalidateIntrinsicContentSize()
        }

    }

    @objc private func addItemGestureRecognizer() -> Void {
        thumbnailDelegate?.didAddItem?(thumbnailView: self)
    }

    @objc private func tapItemGestureRecognizer(gesture: UITapGestureRecognizer) -> Void {

        let index = gesture.view?.tag
        thumbnailDelegate?.thumbnailView?(thumbnailView: self, didSelectItemAt: index! - baseTag)

    }

    private func constraints(vf: String,
                             options: NSLayoutFormatOptions,
                             metrics: [String: Any]?,
                             views: [String: Any]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: vf,
                                              options: options,
                                              metrics: metrics,
                                              views: views)
    }

}
