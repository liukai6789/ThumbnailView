//
//  ViewController.swift
//  ThumbnailViewDemo
//
//  Created by 刘凯 on 2018/8/6.
//  Copyright © 2018年 刘凯. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var thumbnailView1     = ThumbnailView()
    var thumbnailView2     = ThumbnailView()

    var array1 = [Int]()
    var array2 = [Int]()

    var testIndex = 1


    override func viewDidLoad() {
        super.viewDidLoad()

        /// 固定高度的ThumbnailView
        self.view.addSubview(thumbnailView1)
        thumbnailView1.thumbnailDelegate = self
        thumbnailView1.maxCount = 10
        thumbnailView1.backgroundColor = UIColor.gray

        thumbnailView1.translatesAutoresizingMaskIntoConstraints = false
        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[thumbnailView1]-20-|",
                                                  options: .directionLeadingToTrailing,
                                                  metrics: nil,
                                                  views: ["thumbnailView1": thumbnailView1])
        self.view.addConstraints(cons)
        cons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-60-[thumbnailView1(180)]",
                                              options: .directionLeadingToTrailing,
                                              metrics: nil,
                                              views: ["thumbnailView1": thumbnailView1])
        self.view.addConstraints(cons)


        /// 自适应高度的ThumbnailView
        self.view.addSubview(thumbnailView2)
        thumbnailView2.thumbnailDelegate = self
        thumbnailView2.itemSize = CGSize(width: 70, height: 100)
        thumbnailView2.maxCount = 13
        thumbnailView2.backgroundColor = UIColor.gray

        thumbnailView2.translatesAutoresizingMaskIntoConstraints = false
        cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[thumbnailView2]-20-|",
                                              options: .directionLeadingToTrailing,
                                              metrics: nil,
                                              views: ["thumbnailView2": thumbnailView2])
        self.view.addConstraints(cons)
        cons = NSLayoutConstraint.constraints(withVisualFormat: "V:[thumbnailView1]-30-[thumbnailView2]",
                                              options: .directionLeadingToTrailing,
                                              metrics: nil,
                                              views: ["thumbnailView1": thumbnailView1,
                                                      "thumbnailView2": thumbnailView2])
        self.view.addConstraints(cons)
    }

}

extension ViewController: ThumbnailViewDelegate {
    func numberOfItems(thumbnailView: ThumbnailView) -> Int {
        return thumbnailView == thumbnailView1 ? array1.count : array2.count
    }

    func thumbnailView(thumbnailView: ThumbnailView, itemFor index: Int) -> ThumbnailViewItem {
        if thumbnailView == thumbnailView1 {
            let image = UIImage(named: index % 2 == 0 ? "test1" : "test2")
            let item = SimpleThumbnailViewItem.init(image: image)
            return item
        } else {
            let item = Bundle.main.loadNibNamed("MyItem", owner: nil, options: nil)![0] as! MyItem
            let label = item.viewWithTag(2) as! UILabel
            label.text = "\(array2[index])"
            item.deleteClosure = {
                self.array2.remove(at: index)
                thumbnailView.reloadData()
            }
            return item
        }
    }

    func thumbnailView(thumbnailView: ThumbnailView, didSelectItemAt index: Int) {
        print("select index: \(index)")
    }

    func didAddItem(thumbnailView: ThumbnailView) {
        print("add item action")
        if thumbnailView == thumbnailView1 {
            array1.append(1)
        } else {
            array2.append(testIndex)
            testIndex += 1
        }

        thumbnailView.reloadData()
    }


}

