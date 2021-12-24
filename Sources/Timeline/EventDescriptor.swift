import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
  var dateInterval: DateInterval {get set}
  var isAllDay: Bool {get}
  var text: String {get}
  var attributedText: NSAttributedString? {get}
  var lineBreakMode: NSLineBreakMode? {get}
  var font : UIFont {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var timeLabelText: String {get}
  var timeLabelfont : UIFont {get}
  var timeLabelTextColor: UIColor {get}
  var symbolLabelText: String {get}
  var symbolLabelfont : UIFont {get}
  var symbolLabelTextColor: UIColor {get}
  var backgroundColor: UIColor {get}
  var editedEvent: EventDescriptor? {get set}
  func makeEditable() -> Self
  func commitEditing()
}
