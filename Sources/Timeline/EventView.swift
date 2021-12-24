import UIKit

open class EventView: UIView {
  public var descriptor: EventDescriptor?
  public var color = SystemColors.label
  
  private let stackViewMaxHeight: CGFloat = 20.0
  private var stackViewHeight: CGFloat = 0.0

  public var contentHeight: CGFloat {
    return (textView.frame.height + stackView.frame.height)
  }

  public lazy var textView: UITextView = {
    let view = UITextView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    return view
  }()
  
  public lazy var stackView: UIStackView = {
    let stack = UIStackView()
    stack.distribution = .equalSpacing
    stack.axis = .horizontal
    stack.backgroundColor = .clear
    stack.isLayoutMarginsRelativeArrangement = true
    stack.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    stack.addArrangedSubview(symbolLabel)
    stack.addArrangedSubview(timeLabel)
    return stack
  }()
  
  public lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    return label
  }()
  
  public lazy var symbolLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    return label
  }()
  
//  public var imageView: UIImageView = {
//    let image = UIImageView()
//    image.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//    return image
//  }()
  

  /// Resize Handle views showing up when editing the event.
  /// The top handle has a tag of `0` and the bottom has a tag of `1`
  public lazy var eventResizeHandles = [EventResizeHandleView(), EventResizeHandleView()]

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  private func configure() {
    clipsToBounds = false
    color = tintColor
    
    addSubview(textView)
    addSubview(stackView)

    for (idx, handle) in eventResizeHandles.enumerated() {
      handle.tag = idx
      addSubview(handle)
    }
  }

  public func updateWithDescriptor(event: EventDescriptor) {
    if let attributedText = event.attributedText {
      textView.attributedText = attributedText
    } else {
      textView.text = event.text
      textView.textColor = event.textColor
      textView.font = event.font
      timeLabel.text = event.timeLabelText
      timeLabel.textColor = event.timeLabelTextColor
      timeLabel.font = event.timeLabelfont
      symbolLabel.text = event.symbolLabelText
      symbolLabel.textColor = event.symbolLabelTextColor
      symbolLabel.font = event.symbolLabelfont
    }
    if let lineBreakMode = event.lineBreakMode {
      textView.textContainer.lineBreakMode = lineBreakMode
    }
    descriptor = event
    backgroundColor = event.backgroundColor
    color = event.color
    eventResizeHandles.forEach{
      $0.borderColor = event.color
      $0.isHidden = event.editedEvent == nil
    }
    drawsShadow = event.editedEvent != nil
    setNeedsDisplay()
    setNeedsLayout()
  }
  
  public func animateCreation() {
    transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    func scaleAnimation() {
      transform = .identity
    }
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   usingSpringWithDamping: 0.2,
                   initialSpringVelocity: 10,
                   options: [],
                   animations: scaleAnimation,
                   completion: nil)
  }

  /**
   Custom implementation of the hitTest method is needed for the tap gesture recognizers
   located in the ResizeHandleView to work.
   Since the ResizeHandleView could be outside of the EventView's bounds, the touches to the ResizeHandleView
   are ignored.
   In the custom implementation the method is recursively invoked for all of the subviews,
   regardless of their position in relation to the Timeline's bounds.
   */
  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    for resizeHandle in eventResizeHandles {
      if let subSubView = resizeHandle.hitTest(convert(point, to: resizeHandle), with: event) {
        return subSubView
      }
    }
    return super.hitTest(point, with: event)
  }

  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    context.interpolationQuality = .none
    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(3)
    context.translateBy(x: 0, y: 0.5)
    let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
    let x: CGFloat = leftToRight ? 0 : frame.width - 1  // 1 is the line width
    let y: CGFloat = 0
    context.beginPath()
    context.move(to: CGPoint(x: x, y: y))
    context.addLine(to: CGPoint(x: x, y: (bounds).height))
    context.strokePath()
    context.restoreGState()
  }

  private var drawsShadow = false

  override open func layoutSubviews() {
    super.layoutSubviews()
    
    if bounds.height < 40 {
      stackViewHeight = bounds.height - 15
    } else {
      stackViewHeight = stackViewMaxHeight
    }
    
    
    textView.frame = {
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
            return CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width - 3, height: bounds.height - stackViewHeight)
        } else {
            return CGRect(x: bounds.minX + 3, y: bounds.minY, width: bounds.width - 3, height: bounds.height - stackViewHeight)
        }
    }()
    
   
    stackView.frame = {
      return CGRect(x: bounds.minX, y: textView.frame.height, width: bounds.width - 3, height: stackViewHeight)
    }()
    
    if frame.minY < 0 {
      var textFrame = textView.frame;
      textFrame.origin.y = frame.minY * -1;
      textFrame.size.height += frame.minY;
      textView.frame = textFrame;
      stackView.frame = textFrame;
    }
    print(bounds.height)
    let first = eventResizeHandles.first
    let last = eventResizeHandles.last
    let radius: CGFloat = 40
    let yPad: CGFloat =  -radius / 2
    let width = bounds.width
    let height = bounds.height
    let size = CGSize(width: radius, height: radius)
    first?.frame = CGRect(origin: CGPoint(x: width - radius - layoutMargins.right, y: yPad),
                          size: size)
    last?.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: height - yPad - radius),
                         size: size)
    
    if drawsShadow {
      applySketchShadow(alpha: 0.13,
                        blur: 10)
    }
  }

  private func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = alpha
    layer.shadowOffset = CGSize(width: x, height: y)
    layer.shadowRadius = blur / 2.0
    if spread == 0 {
      layer.shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
