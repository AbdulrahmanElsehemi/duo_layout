import Flutter
import UIKit

/// Makes the "…" buttons Dart lays over its own disc at the foot of the
/// status bar's column (`SideToolbarMenuButton`).
final class DuoMenuButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    DuoMenuButton(frame: frame, viewId: viewId, arguments: args, messenger: messenger)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

/// A clear button the size of the disc under it. A tap opens iOS's own
/// pull-down menu from it, as the "…" of Apple's apps does; the item picked
/// goes back to Dart by its index, on the view's own channel.
///
/// The arguments, and an `update` call when Dart's items change:
/// `tooltip` (read out by VoiceOver) and `items`, each `id`, `title`,
/// `image` (an SF Symbol, or null), `destructive` and `enabled`.
final class DuoMenuButton: NSObject, FlutterPlatformView {
  private let button = UIButton(type: .system)
  private let channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, arguments: Any?, messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "iphone_duo/menu_button_\(viewId)", binaryMessenger: messenger)
    super.init()
    button.frame = frame
    button.backgroundColor = .clear
    button.showsMenuAsPrimaryAction = true
    configure(arguments)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "update" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.configure(call.arguments)
      result(nil)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView { button }

  private func configure(_ arguments: Any?) {
    guard let arguments = arguments as? [String: Any] else { return }
    button.accessibilityLabel = arguments["tooltip"] as? String
    let items = arguments["items"] as? [[String: Any]] ?? []
    button.menu = UIMenu(
      children: items.compactMap { item -> UIMenuElement? in
        guard let id = item["id"] as? Int, let title = item["title"] as? String else {
          return nil
        }
        var attributes: UIMenuElement.Attributes = []
        if item["destructive"] as? Bool == true { attributes.insert(.destructive) }
        if item["enabled"] as? Bool == false { attributes.insert(.disabled) }
        let image = (item["image"] as? String).flatMap { UIImage(systemName: $0) }
        return UIAction(title: title, image: image, attributes: attributes) { [weak self] _ in
          self?.channel.invokeMethod("selected", arguments: id)
        }
      })
  }
}
