part of 'qrscan.dart';

class QROverlay extends ShapeBorder {
  final Color borderColor, overlayColor;
  final double borderSize, borderRadius, borderLength, cutOutSize;

  QROverlay({
    this.borderColor = const Color(0xFF00B46E), // 边框颜色
    this.borderSize = 10, // 边框粗细
    this.overlayColor = Colors.black87, // 背景色
    this.borderRadius = 10, // 圆角半径
    this.borderLength = 36, // 边框长度
    this.cutOutSize = 300, // 扫码区域大小
  }) : assert(
            cutOutSize != null ??
                cutOutSize != null ??
                borderLength <= cutOutSize / 2 + borderSize * 2,
            "Border can't be larger than ${cutOutSize / 2 + borderSize * 2}");

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Path _path(Rect rect) => Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top);

    return _path(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    final double width = rect.width,
        height = rect.height,
        borderWidthSize = width / 2,
        borderOffset = borderSize / 2,
        _borderLength = borderLength > cutOutSize / 2 + borderSize * 2
            ? borderWidthSize / 2
            : borderLength,
        _cutOutSize = cutOutSize != null && cutOutSize < width
            ? cutOutSize
            : width - borderOffset;

    final Paint background = Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill,
        border = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderSize,
        view = Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.dstOut;

    final Rect cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, background)
      ..drawRect(rect, background)
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - _borderLength,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + _borderLength,
          topRight: Radius.circular(borderRadius),
        ),
        border, // 右上角
      )
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + _borderLength,
          cutOutRect.top + _borderLength,
          topLeft: Radius.circular(borderRadius),
        ),
        border, // 左上角
      )
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - _borderLength,
          cutOutRect.bottom - _borderLength,
          cutOutRect.right,
          cutOutRect.bottom,
          bottomRight: Radius.circular(borderRadius),
        ),
        border, // 右下角
      )
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.bottom - _borderLength,
          cutOutRect.left + _borderLength,
          cutOutRect.bottom,
          bottomLeft: Radius.circular(borderRadius),
        ),
        border, // 左下角
      )
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        view,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) => QROverlay(
      borderColor: borderColor,
      borderSize: borderSize,
      overlayColor: overlayColor);
}
