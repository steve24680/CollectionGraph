//
//  CollectionGraphView.swift
//  CollectionGraph
//
//  Created by Ben Lambert on 9/23/16.
//  Copyright © 2016 Collective Idea. All rights reserved.
//

import UIKit

/**
 CollectionGraphView requires its data to conform to GraphDatum.  
 
 You may create a struct that conforms to, but also supplies more information.  
 You will be able to access that information during callbacks so you can customize Cells, Bar lines, and Line views.
*/
public protocol GraphDatum {
    var point: CGPoint { get set }
}

public enum ReuseIDs: String {
    case GraphCell = "GraphCell"
    case LineConnectorView = "LineView"
    case BarView = "BarView"
    case YDividerView = "YDivider"
    case XLabelView = "XLabel"
}

@IBDesignable
public class CollectionGraphView: UIView {

    /// Each GraphDatum array will define a new section in the graph.
    public var graphData: [[GraphDatum]]? {
        didSet {
            if let graphData = graphData {
                layout.graphData = graphData
                collectionGraphDataSource.graphData = graphData
                graphCollectionView.reloadData()
            }
        }
    }

    var collectionGraphDataSource = CollectionGraphDataSource()

    /// A graphCell represents a data point on the graph.
    public var graphCell: UICollectionViewCell? {
        didSet {
            if let graphCell = graphCell {
                self.graphCollectionView.register(graphCell.classForCoder, forCellWithReuseIdentifier: ReuseIDs.GraphCell.rawValue)
            }
        }
    }
    
    /// A barCell represents the bar that sits under a graphCell and extends to the bottom of the graph.  Regular bar graph stuff.
    public var barCell: UICollectionReusableView? {
        didSet {
            if let barCell = barCell {
                self.graphCollectionView.register(barCell.classForCoder, forSupplementaryViewOfKind: ReuseIDs.BarView.rawValue, withReuseIdentifier: ReuseIDs.BarView.rawValue)
            }
        }
    }

    private var layout = GraphLayout()

    /// The color of the labels on the x and y axes.
    @IBInspectable public var textColor: UIColor = UIColor.darkText {
        didSet {
            collectionGraphDataSource.textColor = textColor
            graphCollectionView.reloadData()
        }
    }
    
    @IBInspectable public var textSize: CGFloat = 8 {
        didSet {
            collectionGraphDataSource.textSize = textSize
        }
    }

    /// The color of the horizontal lines that run across the graph.
    @IBInspectable public var yDividerLineColor: UIColor = UIColor.lightGray {
        didSet {
            collectionGraphDataSource.yDividerLineColor = yDividerLineColor
            graphCollectionView.reloadData()
        }
    }

    /// The number of horizonal lines and labels to display on the graph along the y axis
    @IBInspectable public var ySteps: Int = 6 {
        didSet{
            layout.ySteps = ySteps
            graphCollectionView.reloadData()
        }
    }
    
    /// The number of labels to display along the x axis.
    @IBInspectable public var xSteps: Int = 3 {
        didSet {
            layout.xSteps = xSteps
            graphCollectionView.reloadData()
        }
    }

    /// Distance offset from the top of the view
    @IBInspectable public var topInset: CGFloat = 10 {
        didSet {
            graphCollectionView.contentInset.top = topInset
            graphCollectionView.reloadData()
        }
    }
    
    /**
    Distance offset from the left side of the view.
     
    This makes space for the y labels.
    */
    @IBInspectable public var leftInset: CGFloat = 20 {
        didSet {
            graphCollectionView.contentInset.left = leftInset
            graphCollectionView.reloadData()
        }
    }
    
    /**
     Distance offset from the bottom of the view.
     
     This makes space for the x labels.
     */
    @IBInspectable public var bottomInset: CGFloat = 20 {
        didSet {
            graphCollectionView.contentInset.bottom = bottomInset
            graphCollectionView.reloadData()
        }
    }
    
    /// Distance offset from the right of the view
    @IBInspectable public var rightInset: CGFloat = 20 {
        didSet {
            graphCollectionView.contentInset.right = rightInset
            graphCollectionView.reloadData()
        }
    }

    @IBOutlet internal weak var graphCollectionView: UICollectionView! {
        didSet {
            graphCollectionView.dataSource = collectionGraphDataSource
            graphCollectionView.collectionViewLayout = layout

            graphCollectionView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            graphCollectionView.contentOffset.x = -leftInset

            registerDefaultCells()
        }
    }
    
    func registerDefaultCells() {
        self.graphCollectionView.register(YDividerLineView.classForCoder(), forSupplementaryViewOfKind: ReuseIDs.YDividerView.rawValue, withReuseIdentifier: ReuseIDs.YDividerView.rawValue)

        self.graphCollectionView.register(XLabelView.classForCoder(), forSupplementaryViewOfKind: ReuseIDs.XLabelView.rawValue, withReuseIdentifier: ReuseIDs.XLabelView.rawValue)
    }
    
    // MARK: - Callbacks
    
    /**
     Callback that returns the graphCell and corresponding GraphDatum.
     
     Use this to set any properties on the graphCell like color, layer properties, or any custom visual properties from your subclass.
    */
    public func setCellProperties(cellCallback: @escaping (_ cell: UICollectionViewCell, _ data: GraphDatum) -> ()) {
        collectionGraphDataSource.cellCallback = cellCallback
    }

    /// Callback to set the size of the graphCell
    public func setCellSize(layoutCallback: @escaping (_ data: GraphDatum) -> (CGSize)) {
        layout.cellLayoutCallback = layoutCallback
    }
    
    /**
     Callback that returns the barCell and corresponding GraphDatum.
     
     Use this to set any properties on the barCell like color, layer properties, or any custom visual properties from your subclass.
    */
    public func setBarViewProperties(cellCallback: @escaping (_ cell: UICollectionReusableView, _ data: GraphDatum) -> ()) {
        if barCell == nil {
            barCell = UICollectionReusableView()
        }
        
        layout.displayBars = true
        collectionGraphDataSource.barCallback = cellCallback
    }
    
    /// Callback to set the width of the barCell
    public func setBarViewWidth(layoutCallback: @escaping (_ data: GraphDatum) -> (CGFloat)) {
        layout.barLayoutCallback = layoutCallback
    }
    
    /**
     Callback that returns the Connector Lines and corresponding GraphDatum.
     
     This is a CAShapeLayer with an extra straightLines Bool.
     
     Use this to set any properties on the line like color, dot patter, cap, or any custom visual properties from your subclass.
    */
    public func setLineViewProperties(lineCallback: @escaping (_ line: GraphLineShapeLayer, _ data: GraphDatum) -> ()) {
        layout.displayLineConnectors = true
        
        self.graphCollectionView.register(LineConnectorView.classForCoder(), forSupplementaryViewOfKind: ReuseIDs.LineConnectorView.rawValue, withReuseIdentifier: ReuseIDs.LineConnectorView.rawValue)
        
        collectionGraphDataSource.lineCallback = lineCallback
    }

    // MARK: - View Lifecycle

    // TODO: Remove layout as a parameter
    required public init(frame: CGRect, layout: GraphLayout, graphCell: UICollectionViewCell) {
        super.init(frame: frame)

        addCollectionView()

        self.layout = layout
        self.graphCell = graphCell
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addCollectionView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addCollectionView()

        defer {
            graphCell = UICollectionViewCell()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layout.invalidateLayout()
    }

    func addCollectionView() {
        let xibView = XibLoader.viewFromXib(name: "GraphCollectionView", owner: self)

        xibView?.frame = bounds

        if let xibView = xibView {
            addSubview(xibView)
        }
    }

}
