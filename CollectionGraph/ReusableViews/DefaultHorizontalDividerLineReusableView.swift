
import UIKit

public class DefaultHorizontalDividerLineReusableView: BaseHorizontalDividerLineReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        line.lineWidth = 1
        line.lineDashPattern = [1, 3]
        line.strokeColor = UIColor.lightGray.cgColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
