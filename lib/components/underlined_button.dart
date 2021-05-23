import 'package:flutter/material.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class UnderlinedButton extends StatefulWidget {
  final Widget child;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onTap;

  const UnderlinedButton({
    Key key,
    @required this.child,
    this.leading,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  _UnderlinedButtonState createState() => _UnderlinedButtonState();
}

class _UnderlinedButtonState extends State<UnderlinedButton>
    with AnimationMixin {
  Animation<Offset> _slideAnimation;
  Animation<double> _underlineAnimation;

  double right;
  double width = 0.0;

  @override
  void initState() {
    super.initState();

    _slideAnimation =
        Offset.zero.tweenTo(Offset(0.2, 0.0)).animatedBy(controller);

    _underlineAnimation = 50.0.tweenTo(0.0).animatedBy(controller);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (bool isHit) {
        if (isHit) {
          right = 40.0;
          width = null;
          controller.play(duration: 500.milliseconds);

          _underlineAnimation.addListener(underlineAnimListener);

          return;
        }

        _underlineAnimation.removeListener(underlineAnimListener);

        right = null;
        width = 0.0;
        controller.playReverse(duration: 500.milliseconds);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null) widget.leading,
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: Stack(
              children: [
                widget.child,
                Positioned(
                  left: 0.0,
                  right: right,
                  width: width,
                  bottom: 0.0,
                  child: Container(
                    color: stateColors.primary,
                    height: 2.0,
                  ),
                ),
              ],
            ),
          ),
          if (widget.trailing != null)
            SlideTransition(
              position: _slideAnimation,
              child: widget.trailing,
            ),
        ],
      ),
    );
  }

  void underlineAnimListener() {
    right = _underlineAnimation.value;
  }
}
