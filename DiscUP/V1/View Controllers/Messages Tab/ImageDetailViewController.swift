//
//  ImageDetailViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/28/21.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    //  MARK: - PROPERTIES
    var imageView = UIImageView()

    //  MARK: - LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        
        //imageView.image = #imageLiteral(resourceName: "DGBasket")
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        let imageWidth = imageView.image?.size.width ?? 0
        let imageHeight = imageView.image?.size.height ?? 0
        
        let imageViewHeight = view.width * imageHeight / imageWidth
        let imageViewWidth = view.height * imageWidth / imageHeight
        
        imageView.frame = CGRect(x: view.left, y: (view.height/2 - imageViewHeight/2), width: view.width, height: imageViewHeight)
        
        if imageView.height > view.height {
            imageView.frame = CGRect(x: (view.width/2 - imageViewWidth/2), y: view.safeAreaInsets.top, width: imageViewWidth, height: view.height)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewLayoutMarginsDidChange() {
        
    }
    
    
}
