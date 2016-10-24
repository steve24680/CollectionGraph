//
//  CollectionGraphDataSource.swift
//  CollectionGraph
//
//  Created by Ben Lambert on 9/29/16.
//  Copyright © 2016 Collective Idea. All rights reserved.
//

import UIKit

class CollectionGraphDataSource: NSObject, UICollectionViewDataSource {

    var graphData: [GraphData]?
    
    internal var cellCallback: ((_ cell: UICollectionViewCell, _ data: GraphData) -> ())?

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return graphData?.numberOfSections() ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return graphData?.filterBySection(section).count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIDs.GraphCell.rawValue, for: indexPath)

        if let graphData = graphData, let cellCallback = cellCallback {
            cellCallback(cell, graphData.filterBySection(indexPath.section)[indexPath.item])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case ReuseIDs.YDividerSupplementaryView.rawValue:

            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseIDs.YDividerSupplementaryView.rawValue, for: indexPath)

        case ReuseIDs.LineSupplementaryView.rawValue:

            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseIDs.LineSupplementaryView.rawValue, for: indexPath)

        case ReuseIDs.XLabelView.rawValue:

            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseIDs.XLabelView.rawValue, for: indexPath)

        default:

            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseIDs.YDividerSupplementaryView.rawValue, for: indexPath)
        }
    }

}
