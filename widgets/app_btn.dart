import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h_world/module/h_world.dart';

class AppBtn extends StatelessWidget {
  final Function onPressed;
  final IconData leftIcon;
  final IconData rightIcon;
  final String title;
  final Color color;
  final Color disableBgColor;
  final Color borderColor;
  final Color textColor;
  final double width;
  final EdgeInsets padding;
  final Color disableTextColor;
  final Color _disableColor = Color(0xff9f9f9f);

  AppBtn(this.title,
      {this.onPressed,
      this.width,
      this.leftIcon,
      this.rightIcon,
      this.textColor = Colors.white,
      this.borderColor,
      this.padding,
      this.color = AppColor.main,
      this.disableTextColor = const Color(0xff9f9f9f),
      this.disableBgColor = const Color(0xff707070)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _CupertinoButton(
        color: color,
        padding: this.padding,
        disabledColor: this.disableBgColor,
        borderColor: borderColor,
        borderDisableColor: this.disableBgColor,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _icon(leftIcon),
            Text(
              title,
              style: TextStyle(
                  color: onPressed != null ? textColor : disableTextColor),
            ),
            _icon(rightIcon),
          ],
        ),
      ),
    );
  }

  Widget _icon(IconData data) => data != null
      ? Icon(
          leftIcon,
          color: this.onPressed != null ? textColor : _disableColor,
        )
      : SizedBox.shrink();
}

class _CupertinoButton extends StatefulWidget {
  const _CupertinoButton({
    Key key,
    @required this.child,
    this.padding,
    this.color,
    this.borderColor = CupertinoColors.quaternarySystemFill,
    this.borderDisableColor,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = 44,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    @required this.onPressed,
  })  : assert(pressedOpacity == null ||
            (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        assert(disabledColor != null),
        _filled = false,
        super(key: key);

  const _CupertinoButton.filled({
    Key key,
    @required this.child,
    this.padding,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = 44,
    this.borderColor = CupertinoColors.quaternarySystemFill,
    this.borderDisableColor,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    @required this.onPressed,
  })  : assert(pressedOpacity == null ||
            (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        assert(disabledColor != null),
        color = null,
        _filled = true,
        super(key: key);
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color disabledColor;
  final Color borderColor;
  final Color borderDisableColor;
  final VoidCallback onPressed;
  final double minSize;

  final double pressedOpacity;

  final BorderRadius borderRadius;

  final bool _filled;

  bool get enabled => onPressed != null;

  @override
  _CupertinoButtonState createState() => _CupertinoButtonState();
}

class _CupertinoButtonState extends State<_CupertinoButton>
    with SingleTickerProviderStateMixin {
  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(_CupertinoButton old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final CupertinoThemeData themeData = CupertinoTheme.of(context);
    final Color primaryColor = themeData.primaryColor;
    final Color backgroundColor = widget.color == null
        ? (widget._filled ? primaryColor : null)
        : CupertinoDynamicColor.resolve(widget.color, context);

    final Color foregroundColor = backgroundColor != null
        ? themeData.primaryContrastingColor
        : enabled
            ? primaryColor
            : CupertinoDynamicColor.resolve(
                CupertinoColors.placeholderText, context);

    final TextStyle textStyle =
        themeData.textTheme.textStyle.copyWith(color: foregroundColor);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: widget.minSize == null
              ? const BoxConstraints()
              : BoxConstraints(
                  minWidth: widget.minSize,
                  minHeight: widget.minSize,
                ),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: enabled && widget.borderColor != null
                    ? _border(widget.borderColor)
                    : !enabled && widget.borderDisableColor != null
                        ? _border(widget.borderDisableColor)
                        : null,
                borderRadius: widget.borderRadius,
                color: backgroundColor != null && !enabled
                    ? CupertinoDynamicColor.resolve(
                        widget.disabledColor, context)
                    : backgroundColor,
              ),
              child: Padding(
                padding: widget.padding ??
                    (backgroundColor != null
                        ? _kBackgroundButtonPadding
                        : _kButtonPadding),
                child: Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: DefaultTextStyle(
                    style: textStyle,
                    child: IconTheme(
                      data: IconThemeData(color: foregroundColor),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _border(Color color) => Border.all(width: 1, color: color);
}

const EdgeInsets _kButtonPadding = EdgeInsets.all(16.0);
const EdgeInsets _kBackgroundButtonPadding = EdgeInsets.symmetric(
  vertical: 14.0,
  horizontal: 64.0,
);
