//
//  CGImageCollectionVC.swift
//  CGODemoApp
//
//  Created by rajkumar.sharma on 5/10/18.
//  Copyright © 2018 rajkumar.sharma. All rights reserved.
//

import UIKit

class CGImageCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSourceArray = [CGImageModal]()
    var refresher:UIRefreshControl!

    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    //MARK: Private functions
    private func initialSetup() {
        loadDataFromServer()
        
        // setup refresh control
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }
    
    @objc private func refreshData() {
        stopRefresher()
    }
    
    private func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    //MARK: UICollectionViewDataSource and Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataSourceArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CGImageCollectionViewCell", for: indexPath) as! CGImageCollectionViewCell
        
        let modal = self.dataSourceArray[indexPath.row]
        cell.avatar.normalLoad(modal.imageHref)
        cell.titleLabel.text = modal.title
        DispatchQueue.main.async(execute: {
            cell.avatar.image = UIImage(named: "placeholder")!
        })
        
        if let url = URL(string: modal.imageHref) {
            
            if let imageD = modal.image {
                cell.avatar.image = imageD
                DispatchQueue.main.async(execute: {
                    cell.avatar.image = imageD
                })
            } else {
                // image caching and lazy loading
                cell.avatar.sd_setImage(with: url) { (image, error, cacheType, url) in
                    if let image = image {
                        self.dataSourceArray[indexPath.row].image = image
                        cell.avatar.image = image
                        // update in main thread
                        DispatchQueue.main.async(execute: {
                            cell.avatar.image = image
                        })
                        self.collectionView.collectionViewLayout.invalidateLayout()
                    } else {
                        
                    }
                }
            }
        }
        
        cell.onTappingImage = {
            () -> Void in
            
            // user tapped on image, push to datail screen
            let previewDataVC = self.storyboard?.instantiateViewController(withIdentifier: "CGPreviewDataVC") as! CGPreviewDataVC
            previewDataVC.dataModal = modal
            self.navigationController?.pushViewController(previewDataVC, animated: true)
        }
        
        return cell
    }
    
    //MARK:- UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // resturn custom layout based on image size if available
        if let image = dataSourceArray[indexPath.item].image {
            return CGSize(width: min(image.size.width, collectionView.frame.size.width), height: image.size.height)
        }
        
        let width = self.collectionView.frame.size.width
        return CGSize(width: width, height: 200)
    }
    
    /*
     Handle layout for rotations between landscape and portrait mode
 */
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK:- Web api section
    
    private func loadDataFromServer() {
        
        ServiceHelper.request(params: [:], method: .get, apiName: "facts.json") { (response, error, httpCode) in
            self.stopRefresher()
            if let error = error {
                AlertController.alert(title: error.localizedDescription)
            } else {
             
                if let infoDictionary = response as? Dictionary<String, AnyObject> {
                    let collectionModal = CGCollectionModal(object: infoDictionary)
                    self.title = collectionModal.title
                    self.dataSourceArray = collectionModal.rows
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
