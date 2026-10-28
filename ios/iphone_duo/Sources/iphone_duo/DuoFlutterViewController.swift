import Flutter
import UIKit

/// The app's root view controller, in place of `FlutterViewController`, so
/// that a screen can keep the status bar and the bars across the top on the
/// iPhone Duo rather than down a column (`NoVerticalBar` in Dart): iOS asks
/// the view controller for its `preferredVerticalBarBehavior`, and Flutter's
/// own cannot be told.
///
/// Set it as the root's class in `Main.storyboard` (Custom Class:
/// `DuoFlutterViewController`, no module), or create it where the app
/// creates its `FlutterViewController`. It is a `FlutterViewController` in
/// every other way.
@objc(DuoFlutterViewController)
open class DuoFlutterViewController: FlutterViewController {
  /// Whether the bars stay across the top and the foot. Set by the plugin
  /// while a `NoVerticalBar` is showing.
  public var verticalBarDisabled = false {
    didSet {
      guard verticalBarDisabled != oldValue else { return }
      #if canImport(UIKit, _version: 9127.0.85)
        if #available(iOS 27.1, *) {
          setNeedsUpdateOfVerticalBarConfiguration()
        }
      #endif
    }
  }

  #if canImport(UIKit, _version: 9127.0.85)
    @available(iOS 27.1, *)
    override open var preferredVerticalBarBehavior: UIVerticalBarBehavior {
      verticalBarDisabled ? .disabled : .automatic
    }
  #endif
}
