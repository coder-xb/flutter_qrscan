import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
part 'overlay.dart';

typedef void QRViewCreate(QRViewController controller);

class QRView extends StatefulWidget {
  final QROverlay overlay;
  final QRViewCreate onCreate;

  QRView({
    @required Key key,
    @required this.onCreate,
    this.overlay,
  })  : assert(key != null),
        assert(onCreate != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      platformView(),
      Container(
        decoration: ShapeDecoration(
          shape: widget.overlay ??
              QROverlay(
                borderSize: 10,
                cutOutSize: 300,
                borderRadius: 10,
                borderLength: 36,
                borderColor: Color(0xFF00B46E),
                overlayColor: Colors.black87,
              ),
        ),
      )
    ]);
  }

  Widget platformView() {
    if (defaultTargetPlatform == TargetPlatform.iOS)
      return UiKitView(
        viewType: 'com.plugins.qrscan/qrview',
        onPlatformViewCreated: viewCreated,
        creationParams: _CreationParams.fromWidget(0, 0).toMap(),
        creationParamsCodec: StandardMessageCodec(),
      );

    return AndroidView(
      viewType: 'com.plugins.qrscan/qrview',
      onPlatformViewCreated: viewCreated,
    );
  }

  void viewCreated(int id) {
    widget.onCreate?.call(QRViewController._(id, widget.key));
  }
}

class QRViewController {
  final MethodChannel _channel;
  final StreamController<String> _controller = StreamController<String>();

  QRViewController._(int id, GlobalKey qrKey)
      : _channel = MethodChannel('com.plugins.qrscan/qrview_$id') {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final RenderBox renderBox = qrKey.currentContext.findRenderObject();
      _channel.invokeMethod('setDimensions',
          {'width': renderBox.size.width, 'height': renderBox.size.height});
    }
    _channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case scanMethod:
            if (call.arguments != null)
              _controller.sink.add(call.arguments.toString());
        }
      },
    );
  }

  static const scanMethod = 'onRecognizeQR';

  Stream<String> get stream => _controller.stream;

  void flipCamera() {
    _channel.invokeMethod('flipCamera');
  }

  void toggleFlash() {
    _channel.invokeMethod('toggleFlash');
  }

  void pauseCamera() {
    _channel.invokeMethod('pauseCamera');
  }

  void resumeCamera() {
    _channel.invokeMethod('resumeCamera');
  }

  void dispose() {
    _controller?.close();
  }
}

class _CreationParams {
  final double width, height;

  _CreationParams({this.width, this.height});

  static _CreationParams fromWidget(double width, double height) =>
      _CreationParams(width: width, height: height);

  Map<String, dynamic> toMap() =>
      <String, dynamic>{'width': width, 'height': height};
}
