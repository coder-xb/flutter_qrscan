import Flutter
import UIKit

public class SwiftQrscanPlugin: NSObject, FlutterPlugin {

  var factory: QRViewFactory
  public init(with registrar: FlutterPluginRegistrar) {
    self.factory = QRViewFactory(withRegistrar: registrar)
    registrar.register(factory, withId: "com.plugins.qrscan/qrview")
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.addApplicationDelegate(SwiftQrscanPlugin(with: registrar))
  }

  public func applicationDidEnterBackground(_ application: UIApplication) {
  }

  public func applicationWillTerminate(_ application: UIApplication) {
  }

}
