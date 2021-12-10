//
//  AllDayEventView.swift
//  CalendarKit
//
//  Created by Bozidar Nikolic on 10.12.21.
//

import UIKit

public final class AllDayEventView: UIView {
  private var style = AllDayEventViewStyle()
  
  private let allDayEventHeight: CGFloat = 24.0
  
  public var events: [EventDescriptor] = [] {
    didSet {
      self.reloadData()
    }
  }
  
  private lazy var stackView: UIStackView = {
    let stack = UIStackView()
    stack.frame = self.bounds
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.distribution = .equalSpacing
    stack.axis = .vertical
    stack.backgroundColor = .clear
    stack.isLayoutMarginsRelativeArrangement = true
    stack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    stack.addArrangedSubview(eventLabel)
    return stack
  }()
  
  private lazy var eventLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Vacation (8h)"
    label.textAlignment = .left
    label.setContentCompressionResistancePriority(.required, for: .horizontal)
    return label
  }()
  
  
  public func reloadData() {
    print("Boza kralj!!!")
  }
  
  // MARK: - RETURN VALUES
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }
  
  private func configure() {
    clipsToBounds = true
    
    addSubview(stackView)
    
    addConstraints([
      //ovaj constraint baca gresku u consoli
      NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
      //ili ovaj :)
      NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),

      NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),

      NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),

      NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24)
    ])
    
    heightAnchor.constraint(lessThanOrEqualToConstant: allDayEventHeight).isActive = true
    updateStyle(style)
  }
  
  public func updateStyle(_ newStyle: AllDayEventViewStyle) {
    style = newStyle
    backgroundColor = style.backgroundColor
    eventLabel.font = style.allDayEventFont
    eventLabel.textColor = style.allDayEventColor
  }
  
  
}

