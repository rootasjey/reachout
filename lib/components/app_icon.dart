import 'package:rootasjey/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatefulWidget {
  final Function onTap;
  final EdgeInsetsGeometry padding;
  final double size;

  AppIcon({
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.size = 40.0,
  });

  @override
  _AppIconState createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: InkWell(
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: widget.onTap ?? defaultOnTap,
        child: Image.asset(
          'assets/images/app_icon/64.png',
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
        ),
      ),
      padding: widget.padding,
    );
  }

  void defaultOnTap() {
    context.router.root.navigate(HomePageRoute());
  }
}
