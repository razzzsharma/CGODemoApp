//
//  CGCustomCollectionLayout.swift
//  CGODemoApp
//
//  Created by rajkumar.sharma on 5/10/18.
//  Copyright © 2018 rajkumar.sharma. All rights reserved.
//

import UIKit

private let kReducedHeightColumnIndex = 1
private let kItemHeightAspect: CGFloat  = 2

class CGCustomCollectionLayout: CGBaseCollectionViewLayout {
    private var _itemSize: CGSize!
    private var _columnsXoffset: [CGFloat]!
    
    //MARK: Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.totalColumns = 3
    }
    
    //MARK: Override getters
    override var description: String {
        return "Layout v1"
    }
    
    //MARK: Override Abstract methods
    override func columnIndexForItemAt(indexPath: IndexPath) -> Int {
        //If last item is single in row, we move it to reduced column, to make it looks nice
        let columnIndex = indexPath.item % totalColumns
        return self.isLastItemSingleInRow(indexPath) ? kReducedHeightColumnIndex : columnIndex
    }
    
    override func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        let rowIndex = indexPath.item / totalColumns
        let halfItemHeight = (_itemSize.height - interItemsSpacing) / 2
        
        //Resolving Item height
        var itemHeight = _itemSize.height
        
        // By our logic, first and last items in reduced height column have height divided by 2.
        if (rowIndex == 0 && columnIndex == kReducedHeightColumnIndex) || self.isLastItemSingleInRow(indexPath) {
            itemHeight = halfItemHeight
        }
        
        return CGRect(x: _columnsXoffset[columnIndex], y: columnYoffset, width: _itemSize.width, height: itemHeight)
    }
    
    override func calculateItemsSize() {
        let contentWidthWithoutIndents = collectionView!.bounds.width - contentInsets.left - contentInsets.right
        let itemWidth = (contentWidthWithoutIndents - (CGFloat(totalColumns) - 1) * interItemsSpacing) / CGFloat(totalColumns)
        let itemHeight = itemWidth * kItemHeightAspect
        
        _itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        // Calculating offsets by X for each column
        _columnsXoffset = []
        
        for columnIndex in 0...(totalColumns - 1) {
            _columnsXoffset.append(CGFloat(columnIndex) * (_itemSize.width + interItemsSpacing))
        }
    }
    
    //MARK: Private methods
    private func isLastItemSingleInRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == (totalItemsInSection - 1) && indexPath.item % totalColumns == 0
    }
}
