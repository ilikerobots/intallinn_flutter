// Adapted with gratitude from flutter_logo.dart

import 'dart:math' as math;
import 'dart:ui' as ui show Gradient, TextBox, lerpDouble;

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// The Intallinn logo, in widget form. This widget respects the [IconTheme].
///
/// See also:
///
///  * [IconTheme], which provides ambient configuration for icons.
///  * [Icon], for showing icons the Material design icon library.
///  * [ImageIcon], for showing icons from [AssetImage]s or other [ImageProvider]s.
class IntallinnLogo extends StatelessWidget {
  /// Creates a widget that paints the Intallinn logo.
  ///
  /// The [size] defaults to the value given by the current [IconTheme].
  const IntallinnLogo({
    Key key,
    this.size,
    this.primaryColor: const Color(0xFF0072CE),
    this.textColor: const Color(0xFF616161),
    this.style: IntallinnLogoStyle.markOnly,
    this.duration: const Duration(milliseconds: 750),
    this.curve: Curves.fastOutSlowIn,
  }) : super(key: key);

  /// The size of the logo in logical pixels.
  ///
  /// The logo will be fit into a square this size.
  ///
  /// Defaults to the current [IconTheme] size, if any. If there is no
  /// [IconTheme], or it does not specify an explicit size, then it defaults to
  /// 24.0.
  final double size;

  /// The primary color for the the logo.
  final Color primaryColor;

  /// The color used to paint the "Intallinn" text on the logo, if [style] is
  /// [IntallinnLogoStyle.horizontal] or [IntallinnLogoStyle.stacked]. The
  /// appropriate color is `const Color(0xFF616161)` (a medium gray), against a
  /// white background.
  final Color textColor;

  /// Whether and where to draw the "Intallinn" text. By default, only the logo
  /// itself is drawn.
  final IntallinnLogoStyle style;

  /// The length of time for the animation if the [style], [primaryColor], or
  /// [textColor] properties are changed.
  final Duration duration;

  /// The curve for the logo animation if the [style], [primaryColor], or [textColor]
  /// change.
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = size ?? iconTheme.size;
    return new AnimatedContainer(
      width: iconSize,
      height: iconSize,
      duration: duration,
      curve: curve,
      decoration: new IntallinnLogoDecoration(
        primaryColor: primaryColor,
        style: style,
        textColor: textColor,
      ),
    );
  }
}

/// Possible ways to draw Intallinn's logo.
enum IntallinnLogoStyle {
  /// Show only Intallinn's logo, not the "Intallinn" label.
  ///
  /// This is the default behavior for [IntallinnLogoDecoration] objects.
  markOnly,

  /// Show Intallinn's logo on the left, and the "Intallinn" label to its right.
  horizontal,

  /// Show Intallinn's logo above the "Intallinn" label.
  stacked,
}

/// An immutable description of how to paint Intallinn's logo.
class IntallinnLogoDecoration extends Decoration {
  /// Creates a decoration that knows how to paint Intallinn's logo.
  ///
  /// [primaryColor] controls the color used for the logo. The [style] controls
  /// whether and where to draw the "Intallinn" label. If one is shown, the
  /// [textColor] controls the color of the label.
  ///
  /// The [primaryColor], [textColor], and [style] arguments must not be null.
  const IntallinnLogoDecoration({
    this.primaryColor: const Color(0xFF0072CE),
    this.textColor: const Color(0xFF616161),
    IntallinnLogoStyle style: IntallinnLogoStyle.markOnly,
    this.margin: EdgeInsets.zero,
  }) : style = style,
        _position = style == IntallinnLogoStyle.markOnly ? 0.0 : style == IntallinnLogoStyle.horizontal ? 1.0 : -1.0, // ignore: CONST_EVAL_TYPE_BOOL_NUM_STRING
        // (see https://github.com/dart-lang/sdk/issues/26980 for details about that ignore statement)
        _opacity = 1.0;

  IntallinnLogoDecoration._(this.primaryColor, this.textColor, this.style,
      this._position, this._opacity, this.margin);

  /// The primary color to use to paint the logo.
  final Color primaryColor;

  /// The color used to paint the "Intallinn" text on the logo, if [style] is
  /// [IntallinnLogoStyle.horizontal] or [IntallinnLogoStyle.stacked]. The
  /// appropriate color is `const Color(0xFF616161)` (a medium gray), against a
  /// white background.
  final Color textColor;

  /// Whether and where to draw the "Intallinn" text. By default, only the logo
  /// itself is drawn.
  // This property isn't actually used when painting. It's only really used to
  // set the internal _position property.
  final IntallinnLogoStyle style;

  // The following are set when lerping, to represent states that can't be
  // represented by the constructor.
  final double _position; // -1.0 for stacked, 1.0 for horizontal, 0.0 for no logo
  final double _opacity; // 0.0 .. 1.0

  /// How far to inset the logo from the edge of the container.
  final EdgeInsets margin;

  bool get _inTransition =>
      _opacity != 1.0 ||
          (_position != -1.0 && _position != 0.0 && _position != 1.0);

  @override
  bool debugAssertIsValid() {
    assert(primaryColor != null
        && textColor != null
        && style != null
        && _position != null
        && _position.isFinite
        && _opacity != null
        && _opacity >= 0.0
        && _opacity <= 1.0
        && margin != null);
    return true;
  }

  @override
  bool get isComplex => !_inTransition;

  /// Linearly interpolate between two Intallinn logo descriptions.
  ///
  /// Interpolates both the color and the style in a continuous fashion.
  ///
  /// See also [Decoration.lerp].
  static IntallinnLogoDecoration lerp(IntallinnLogoDecoration a,
      IntallinnLogoDecoration b, double t) {
    assert(a == null || a.debugAssertIsValid());
    assert(b == null || b.debugAssertIsValid());
    if (a == null && b == null)
      return null;
    if (a == null) {
      return new IntallinnLogoDecoration._(
        b.primaryColor,
        b.textColor,
        b.style,
        b._position,
        b._opacity * t.clamp(0.0, 1.0),
        b.margin * t,
      );
    }
    if (b == null) {
      return new IntallinnLogoDecoration._(
        a.primaryColor,
        a.textColor,
        a.style,
        a._position,
        a._opacity * (1.0 - t).clamp(0.0, 1.0),
        a.margin * t,
      );
    }
    return new IntallinnLogoDecoration._(
      Color.lerp(a.primaryColor, b.primaryColor, t),
      Color.lerp(a.textColor, b.textColor, t),
      t < 0.5 ? a.style : b.style,
      a._position + (b._position - a._position) * t,
      (a._opacity + (b._opacity - a._opacity) * t).clamp(0.0, 1.0),
      EdgeInsets.lerp(a.margin, b.margin, t),
    );
  }

  @override
  IntallinnLogoDecoration lerpFrom(Decoration a, double t) {
    assert(debugAssertIsValid());
    if (a is! IntallinnLogoDecoration)
      return lerp(null, this, t);
    assert(a.debugAssertIsValid);
    return lerp(a, this, t);
  }

  @override
  IntallinnLogoDecoration lerpTo(Decoration b, double t) {
    assert(debugAssertIsValid());
    if (b is! IntallinnLogoDecoration)
      return lerp(this, null, t);
    assert(b.debugAssertIsValid());
    return lerp(this, b, t);
  }

  @override
  // TODO(ianh): better hit testing
  bool hitTest(Size size, Point position) => true;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    assert(debugAssertIsValid());
    return new _IntallinnLogoPainter(this);
  }

  @override
  bool operator ==(dynamic other) {
    assert(debugAssertIsValid());
    if (identical(this, other))
      return true;
    if (other is! IntallinnLogoDecoration)
      return false;
    final IntallinnLogoDecoration typedOther = other;
    return primaryColor == typedOther.primaryColor
        && textColor == typedOther.textColor
        && _position == typedOther._position
        && _opacity == typedOther._opacity;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(
        primaryColor,
        textColor,
        _position,
        _opacity
    );
  }

  @override
  String toString([String prefix = '', String prefixIndent ]) {
    final String extra = _inTransition
        ? ', transition $_position:$_opacity'
        : '';
    if (primaryColor == null)
      return '$prefix$runtimeType(null, $style$extra)';
    return '$prefix$runtimeType($primaryColor on $textColor, $style$extra)';
  }
}


/// An object that paints a [BoxDecoration] into a canvas.
class _IntallinnLogoPainter extends BoxPainter {
  _IntallinnLogoPainter(this._config) : super(null) {
    assert(_config != null);
    assert(_config.debugAssertIsValid());
    _prepareText();
  }

  final IntallinnLogoDecoration _config;

  // these are configured assuming a font size of 100.0.
  TextPainter _textPainter;
  Rect _textBoundingRect;

  void _prepareText() {
    const String kLabel = 'InTallinn';
    _textPainter = new TextPainter(
        text: new TextSpan(
            text: kLabel,
            style: new TextStyle(
                color: _config.textColor,
                fontFamily: 'AlegreyaSansSC',
                fontSize: 100.0 * 350.0 / 247.0,
                // 247 is the height of the F when the fontSize is 350, assuming device pixel ratio 1.0
                fontWeight: FontWeight.w200,
                textBaseline: TextBaseline.alphabetic
            )
        )
    );
    _textPainter.layout();
    final ui.TextBox textSize = _textPainter
        .getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: kLabel.length))
        .single;
    _textBoundingRect = new Rect.fromLTRB(
        textSize.left, textSize.top, textSize.right, textSize.bottom);
  }

  void _paintLogo(Canvas canvas, Rect rect) {
    // Our points are in a coordinate space that's 166 pixels wide and 202 pixels high.
    // First, transform the rectangle so that our coordinate space is a square 202 pixels
    // to a side, with the top left at the origin.
    canvas.save();
    canvas.translate(rect.left, rect.top);
    canvas.scale(rect.width / 202.0, rect.height / 202.0);
    // Next, offset it some more so that the 166 horizontal pixels are centered
    // in that square (as opposed to being on the left side of it). This means
    // that if we draw in the rectangle from 0,0 to 166,202, we are drawing in
    // the center of the given rect.
    canvas.translate(0.00, -860.362260);


    final Paint bgPaint = new Paint()..color = _config.primaryColor;
    final Paint towerPaint = new Paint()..color = Colors.white;
    final Paint shadowPaint = new Paint()..color = Colors.black12;
    final Paint doorPaint = new Paint()..color = Colors.black;

    canvas.save();
    Radius boxRadius = new Radius.circular(20.0);
    final Path square = new Path()
      ..addRRect(new RRect.fromLTRBR(0.0, 860.0, 192.0, 1052.0, boxRadius));
    canvas.drawPath(square, bgPaint);
    canvas.restore();

    final Path tower = new Path()
      ..moveTo(80.409474, 989.108710)
      ..cubicTo(78.614384, 985.100440, 78.006804, 983.958580, 76.927224, 970.578240)
      ..cubicTo(75.713644, 986.506940, 72.400694, 987.706800, 72.369214, 996.470070)
      ..lineTo(72.236554, 1033.400900)..lineTo(120.751930, 1033.400900)
      ..lineTo(120.619280, 996.470070)
      ..cubicTo(120.587780, 987.706800, 117.274840, 986.506930, 116.061260, 970.578240)
      ..cubicTo(114.981690, 983.958580, 114.374110, 985.100440, 112.579020, 989.108710)
      ..cubicTo( 100.083640, 989.108710, 98.415814, 911.437810, 96.494244, 872.258030)
      ..cubicTo( 94.572684, 911.437810, 93.283884, 989.108710, 80.409474, 989.108710);
    canvas.drawPath(tower, towerPaint);

    canvas.save();
    canvas.translate(0.000000, 860.362260);
    final Path shadow = new Path()
      ..moveTo(96.550781, 11.955078)
      ..lineTo(96.505859, 12.000000)
      ..lineTo(96.505859, 172.720700)
      ..lineTo( 72.306641, 172.720700)
      ..lineTo(72.306641, 173.119140)
      ..lineTo(91.187500, 192.000000)
      ..lineTo(170.214840, 192.000000)
      ..cubicTo(182.284120, 192.000000, 192.000000, 182.284120, 192.000000, 170.214840)
      ..lineTo(192.000000, 107.404300)
      ..lineTo(96.550781, 11.955078);
    canvas.drawPath(shadow, shadowPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(-43.942616, 265.685090);

    final Path door1 = new Path()
      ..moveTo(130.074050, 737.530470)
      ..cubicTo(127.229230, 737.530470, 124.939120, 741.425800, 124.939120, 746.264660)
      ..lineTo(124.939120, 752.697460)..lineTo(136.272890, 752.697460)
      ..lineTo(136.272890, 746.264660)
      ..cubicTo(136.272890, 741.425800, 133.982320, 737.530470, 131.137500,737.530470)
      ..lineTo(130.074050, 737.530470);
    canvas.drawPath(door1, doorPaint);

    final Path door2 = new Path()
      ..moveTo(148.747250, 737.530470)
      ..cubicTo(145.902430, 737.530470, 143.612320, 741.425800, 143.612320, 746.264660)
      ..lineTo(143.612320, 752.697460)
      ..lineTo(154.946090, 752.697460)
      ..lineTo(154.946090, 746.264660)
      ..cubicTo(154.946090, 741.425800, 152.655520, 737.530470, 149.810700, 737.530470)
      ..lineTo(148.747250, 737.530470);
    canvas.drawPath(door2, doorPaint);
    canvas.restore(); //doors

    canvas.restore(); //background
    canvas.restore(); //root
  }


  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    offset += _config.margin.topLeft;
    Size canvasSize = _config.margin.deflateSize(configuration.size);
    Size logoSize;
    if (_config._position > 0.0) {
      // horizontal style
      logoSize = const Size(820.0, 232.0);
    } else if (_config._position < 0.0) {
      // stacked style
      logoSize = const Size(252.0, 306.0);
    } else {
      // only the mark
      logoSize = const Size(202.0, 202.0);
    }
    final FittedSizes fittedSize = applyImageFit(
        ImageFit.contain, logoSize, canvasSize);
    assert(fittedSize.source == logoSize);
    final Rect rect = FractionalOffset.center.inscribe(
        fittedSize.destination, offset & canvasSize);
    final double centerSquareHeight = canvasSize.shortestSide;
    final Rect centerSquare = new Rect.fromLTWH(
        offset.dx + (canvasSize.width - centerSquareHeight) / 2.0,
        offset.dy + (canvasSize.height - centerSquareHeight) / 2.0,
        centerSquareHeight,
        centerSquareHeight
    );

    Rect logoTargetSquare;
    if (_config._position > 0.0) {
      // horizontal style
      logoTargetSquare =
      new Rect.fromLTWH(rect.left, rect.top, rect.height, rect.height);
    } else if (_config._position < 0.0) {
      // stacked style
      final double logoHeight = rect.height * 191.0 / 306.0;
      logoTargetSquare = new Rect.fromLTWH(
          rect.left + (rect.width - logoHeight) / 2.0,
          rect.top,
          logoHeight,
          logoHeight
      );
    } else {
      // only the mark
      logoTargetSquare = centerSquare;
    }
    final Rect logoSquare = Rect.lerp(
        centerSquare, logoTargetSquare, _config._position.abs());

    if (_config._opacity < 1.0) {
      canvas.saveLayer(
          offset & canvasSize,
          new Paint()
            ..colorFilter = new ColorFilter.mode(
              const Color(0xFFFFFFFF).withOpacity(_config._opacity),
              BlendMode.modulate,
            )
      );
    }
    if (_config._position != 0.0) {
      if (_config._position > 0.0) {
        // horizontal style
        final double fontSize = 2.0 / 3.0 * logoSquare.height *
            (1 - (10.4 * 2.0) / 202.0);
        final double scale = fontSize / 100.0;
        final double finalLeftTextPosition = // position of text in rest position
        (256.4 / 820.0) * rect
            .width - // 256.4 is the distance from the left edge to the left of the F when the whole logo is 820.0 wide
            (32.0 / 350.0) *
                fontSize; // 32 is the distance from the text bounding box edge to the left edge of the F when the font size is 350
        final double initialLeftTextPosition = // position of text when just starting the animation
        rect.width / 2.0 - _textBoundingRect.width * scale;
        final Offset textOffset = new Offset(
            rect.left + ui.lerpDouble(
                initialLeftTextPosition, finalLeftTextPosition,
                _config._position),
            rect.top + (rect.height - _textBoundingRect.height * scale) / 2.0
        );
        canvas.save();
        if (_config._position < 1.0) {
          final Point center = logoSquare.center;
          final Path path = new Path()
            ..moveTo(center.x, center.y)
            ..lineTo(center.x + rect.width, center.y - rect.width)..lineTo(
                center.x + rect.width, center.y + rect.width)
            ..close();
          canvas.clipPath(path);
        }
        canvas.translate(textOffset.dx, textOffset.dy);
        canvas.scale(scale, scale);
        _textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      } else if (_config._position < 0.0) {
        // stacked style
        final double fontSize = 0.35 * logoTargetSquare.height *
            (1 - (10.4 * 2.0) / 202.0);
        final double scale = fontSize / 100.0;
        if (_config._position > -1.0) {
          canvas.saveLayer(_textBoundingRect, new Paint());
        } else {
          canvas.save();
        }
        canvas.translate(
            logoTargetSquare.center.x - (_textBoundingRect.width * scale / 2.0),
            logoTargetSquare.bottom
        );
        canvas.scale(scale, scale);
        _textPainter.paint(canvas, Offset.zero);
        if (_config._position > -1.0) {
          canvas.drawRect(
              _textBoundingRect.inflate(_textBoundingRect.width * 0.5),
              new Paint()
                ..blendMode = BlendMode.modulate
                ..shader = new ui.Gradient.linear(
                  <Point>[
                    new Point(_textBoundingRect.width * -0.5, 0.0),
                    new Point(_textBoundingRect.width * 1.5, 0.0)
                  ],
                  <Color>[
                    const Color(0xFFFFFFFF),
                    const Color(0xFFFFFFFF),
                    const Color(0x00FFFFFF),
                    const Color(0x00FFFFFF)
                  ],
                  <double>[
                    0.0,
                    math.max(0.0, _config._position.abs() - 0.1),
                    math.min(_config._position.abs() + 0.1, 1.0),
                    1.0
                  ],
                )
          );
        }
        canvas.restore();
      }
    }
    _paintLogo(canvas, logoSquare);
    if (_config._opacity < 1.0)
      canvas.restore();
  }
}
