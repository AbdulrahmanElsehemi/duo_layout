import Flutter
import UIKit

/// Tells duo_layout what iOS knows about the iPhone Duo, which Flutter does
/// not pass on by itself: the side the status bar runs down
/// (`verticalBarEdge`), the hinge, and the regions of the glass taken by the
/// fold (`.division`) and by the camera and status bar (`.occlusion`).
///
/// `snapshot` answers with all of it; `duo_layout/changes` sends it again
/// whenever the hinge moves or the bar changes side. The regions move with
/// the window, so the Dart side asks for a snapshot when the window changes.
///
/// `setVerticalBarDisabled` keeps the status bar and the bars across the top
/// on the screen showing (`preferredVerticalBarBehavior`), through the app's
/// root `DuoFlutterViewController`. `duo_layout/menu_button` is the "…" at
/// the foot of the column: a native button that opens iOS's own menu.
///
/// The APIs are in the iOS 27.1 SDK. Built with an older Xcode, or run on an
/// older iOS, the answer is `available: false` and duo_layout reads the safe
/// area instead.
public class DuoLayoutPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private weak var registrar: FlutterPluginRegistrar?
  private var sink: FlutterEventSink?
  private weak var observed: UIView?
  private var hinge: [String: Any]?
  private var interaction: UIInteraction?
  // A UITraitChangeRegistration, which needs iOS 17.
  private var traitRegistration: Any?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = DuoLayoutPlugin()
    instance.registrar = registrar
    let methods = FlutterMethodChannel(
      name: "duo_layout", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methods)
    let changes = FlutterEventChannel(
      name: "duo_layout/changes", binaryMessenger: registrar.messenger())
    changes.setStreamHandler(instance)
    registrar.register(
      DuoMenuButtonFactory(messenger: registrar.messenger()),
      withId: "duo_layout/menu_button")
    // A storyboard names DuoFlutterViewController only as a string. Linked
    // statically (Swift Package Manager), a class nothing in the code names
    // can be left out, and the app opens on an empty view controller.
    _ = DuoFlutterViewController.self
  }

  /// The Flutter view: from the registrar, or under UIScene, where it can be
  /// missing at first, the key window's root.
  @MainActor
  private var view: UIView? {
    if let view = registrar?.viewController?.view { return view }
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    return scenes.flatMap(\.windows).first(where: \.isKeyWindow)?.rootViewController?.view
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "snapshot":
      // Channels call on the main thread; UIKit wants it said.
      Task { @MainActor in
        self.observe()
        result(self.snapshot())
      }
    case "setVerticalBarDisabled":
      let disabled = call.arguments as? Bool ?? false
      Task { @MainActor in
        result(self.setVerticalBarDisabled(disabled))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    Task { @MainActor in
      self.observe()
      events(self.snapshot())
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    Task { @MainActor in self.stopObserving() }
    return nil
  }

  /// Whether iOS took it: the root has to be a `DuoFlutterViewController`,
  /// and iOS 27.1 or later.
  @MainActor
  private func setVerticalBarDisabled(_ disabled: Bool) -> Bool {
    #if canImport(UIKit, _version: 9127.0.85)
      if #available(iOS 27.1, *) {
        let root = registrar?.viewController ?? view?.window?.rootViewController
        guard let root = root as? DuoFlutterViewController else { return false }
        root.verticalBarDisabled = disabled
        return true
      }
    #endif
    return false
  }

  @MainActor
  private func emit() {
    sink?(snapshot())
  }

  @MainActor
  private func stopObserving() {
    if let interaction { observed?.removeInteraction(interaction) }
    if #available(iOS 17.0, *),
      let registration = traitRegistration as? UITraitChangeRegistration
    {
      observed?.unregisterForTraitChanges(registration)
    }
    interaction = nil
    traitRegistration = nil
    observed = nil
    hinge = nil
  }

  /// Watches the hinge and the bar's side on the Flutter view, once it is
  /// there.
  @MainActor
  private func observe() {
    guard let view, view !== observed else { return }
    stopObserving()
    observed = view
    #if canImport(UIKit, _version: 9127.0.85)
      if #available(iOS 27.1, *) {
        let hingeInteraction = UIHingeInteraction { [weak self] _, update in
          guard let self else { return }
          if let hinge = update.hinge {
            self.hinge = [
              "angle": Double(hinge.angle) * 180 / .pi,
              "status": DuoLayoutPlugin.name(of: hinge.status),
            ]
          } else {
            self.hinge = nil
          }
          self.emit()
        }
        view.addInteraction(hingeInteraction)
        interaction = hingeInteraction
        traitRegistration = view.registerForTraitChanges(
          UITraitCollection.systemTraitsAffectingVerticalBarEdge
        ) { [weak self] (_: UIView, _: UITraitCollection) in
          self?.emit()
        }
      }
    #endif
  }

  @MainActor
  private func snapshot() -> [String: Any] {
    #if canImport(UIKit, _version: 9127.0.85)
      if #available(iOS 27.1, *), let view {
        func regions(_ kind: UIView.ReservedRegion.Kind) -> [[String: Any]] {
          view.reservedRegions(kind: kind, options: .includeInactive).map {
            [
              "frame": [$0.frame.minX, $0.frame.minY, $0.frame.width, $0.frame.height]
                .map(Double.init),
              "margins": [$0.margins.top, $0.margins.left, $0.margins.bottom, $0.margins.right]
                .map(Double.init),
              "active": $0.isActive,
            ]
          }
        }
        // Leading and trailing are the app's reading direction; the column
        // is a side of the glass.
        let rtl = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        let edge: Any =
          switch view.traitCollection.verticalBarEdge {
          case .leading: rtl ? "right" : "left"
          case .trailing: rtl ? "left" : "right"
          default: NSNull()
          }
        return [
          "available": true,
          "barEdge": edge,
          "hinge": hinge ?? NSNull(),
          "folds": regions(.division),
          "occlusions": regions(.occlusion),
        ]
      }
    #endif
    return ["available": false]
  }

  #if canImport(UIKit, _version: 9127.0.85)
    @available(iOS 27.1, *)
    private static func name(of status: UIHinge.Status) -> String {
      switch status {
      case .closed: "closed"
      case .partiallyOpen: "partiallyOpen"
      case .fullyOpen: "fullyOpen"
      default: "unknown"
      }
    }
  #endif
}
