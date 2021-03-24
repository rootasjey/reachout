import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/components/app_icon_header.dart';
import 'package:rootasjey/router/app_router.gr.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/state/user.dart';
import 'package:rootasjey/utils/app_storage.dart';
import 'package:rootasjey/utils/brightness.dart';
import 'package:unicons/unicons.dart';

class HomeAppBar extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final Function onTapIconHeader;
  final Widget title;
  final VoidCallback onPressedRightButton;

  HomeAppBar({
    this.automaticallyImplyLeading = false,
    this.onTapIconHeader,
    this.title,
    this.onPressedRightButton,
  });

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        final isNarrow = constrains.crossAxisExtent < 700.0;
        final leftPadding = isNarrow ? 0.0 : 80.0;

        return SliverAppBar(
          floating: true,
          snap: true,
          pinned: true,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                if (widget.automaticallyImplyLeading)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      color: stateColors.foreground,
                      onPressed: context.router.pop,
                      icon: Icon(UniconsLine.arrow_left),
                    ),
                  ),
                AppIconHeader(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                  ),
                  onTap: widget.onTapIconHeader,
                ),
                if (widget.title != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: widget.title,
                    ),
                  ),
                userSection(isNarrow),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget addNewPostButton() {
    return ElevatedButton(
      onPressed: () {
        context.router.push(DashboardPageRoute(children: [NewPostRoute()]));
      },
      style: ElevatedButton.styleFrom(
        primary: stateColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.add, color: Colors.white),
          ),
          Text(
            'New Post',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchButton() {
    return IconButton(
      onPressed: () {
        context.router.push(SearchRoute());
      },
      color: stateColors.foreground,
      icon: Icon(Icons.search),
    );
  }

  /// Switch from dark to light and vice-versa.

  /// Switch from dark to light and vice-versa.
  Widget brightnessButton() {
    IconData iconBrightness = Icons.brightness_auto;
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appStorage.getBrightness();

      iconBrightness = currentBrightness == Brightness.dark
          ? Icons.brightness_2
          : Icons.brightness_low;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        icon: Icon(
          iconBrightness,
          color: stateColors.foreground.withOpacity(0.6),
        ),
        tooltip: "brightness".tr(),
        onSelected: (value) {
          if (value == 'auto') {
            BrightnessUtils.setAutoBrightness(context);
            return;
          }

          final brightness =
              value == 'dark' ? Brightness.dark : Brightness.light;

          BrightnessUtils.setBrightness(context, brightness);
        },
        itemBuilder: (context) {
          final autoBrightness = appStorage.getAutoBrightness();
          final brightness = autoBrightness ? null : appStorage.getBrightness();

          final primary = stateColors.primary;
          final basic = stateColors.foreground;

          return [
            PopupMenuItem(
              value: 'auto',
              child: ListTile(
                leading: Icon(Icons.brightness_auto),
                title: Text(
                  "auto".tr(),
                  style: TextStyle(
                    color: autoBrightness ? primary : basic,
                  ),
                ),
                trailing: autoBrightness
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'dark',
              child: ListTile(
                leading: Icon(Icons.brightness_2),
                title: Text(
                  "dark".tr(),
                  style: TextStyle(
                    color: brightness == Brightness.dark ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.dark
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'light',
              child: ListTile(
                leading: Icon(Icons.brightness_5),
                title: Text(
                  "light".tr(),
                  style: TextStyle(
                    color: brightness == Brightness.light ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.light
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget userAvatar({bool isNarrow = true}) {
    final arrStr = stateUser.username.split(' ');
    String initials = '';

    if (arrStr.length > 0) {
      initials = arrStr.length > 1
          ? arrStr.reduce((value, element) => value + element.substring(1))
          : arrStr.first;

      if (initials != null && initials.isNotEmpty) {
        initials = initials.substring(0, 1);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: PopupMenuButton<PageRouteInfo>(
        icon: CircleAvatar(
          backgroundColor: stateColors.primary,
          radius: 20.0,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        onSelected: (route) {
          if (route.routeName == SignOutRoute.name) {
            stateUser.signOut(context: context);
            return;
          }

          context.router.push(route);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PageRouteInfo>>[
          if (isNarrow)
            PopupMenuItem(
                value: DashboardPageRoute(children: [NewPostRoute()]),
                child: ListTile(
                  leading: Icon(UniconsLine.plus),
                  title: Text(
                    "post_new".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )),
          if (isNarrow)
            PopupMenuItem(
                value: SearchRoute(),
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text(
                    "search".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )),
          PopupMenuItem(
              value: DashboardPageRoute(children: [NewProjectRoute()]),
              child: ListTile(
                leading: Icon(UniconsLine.plus),
                title: Text(
                  "project_new".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )),
          PopupMenuItem(
            value: DashboardPageRoute(children: [MyPostsRoute()]),
            child: ListTile(
              leading: Icon(Icons.article),
              title: Text(
                "posts_my".tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: DashboardPageRoute(children: [MyProjectsRoute()]),
            child: ListTile(
              leading: Icon(Icons.apps_outlined),
              title: Text(
                "projects_my".tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: SignOutRoute(),
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "signout".tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userSection(bool isNarrow) {
    final children = <Widget>[];

    if (stateUser.isUserConnected) {
      isNarrow
          ? children.addAll([
              userAvatar(isNarrow: isNarrow),
              brightnessButton(),
            ])
          : children.addAll([
              userAvatar(isNarrow: isNarrow),
              addNewPostButton(),
              searchButton(),
              brightnessButton(),
            ]);
    } else {
      isNarrow
          ? children.addAll([
              userSigninMenu(showSearch: true),
              brightnessButton(),
            ])
          : children.addAll([
              if (widget.onPressedRightButton != null)
                IconButton(
                  color: stateColors.foreground,
                  icon: Icon(Icons.menu),
                  onPressed: widget.onPressedRightButton,
                ),
              userSigninMenu(),
              searchButton(),
              brightnessButton(),
            ]);
    }

    return Container(
      padding: const EdgeInsets.only(
        top: 5.0,
        right: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: children,
      ),
    );
  }

  Widget userSigninMenu({bool showSearch = false}) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: stateColors.foreground),
      itemBuilder: (context) => <PopupMenuEntry<PageRouteInfo>>[
        if (showSearch)
          PopupMenuItem(
            value: SearchRoute(),
            child: ListTile(
              leading: Icon(Icons.search),
              title: Text("search".tr()),
            ),
          ),
        PopupMenuItem(
          value: SigninRoute(),
          child: ListTile(
            leading: Icon(Icons.perm_identity),
            title: Text("signin".tr()),
          ),
        ),
        PopupMenuItem(
          value: SignupRoute(),
          child: ListTile(
            leading: Icon(Icons.open_in_browser),
            title: Text("signup".tr()),
          ),
        ),
      ],
      onSelected: (routeInfo) {
        context.router.push(routeInfo);
      },
    );
  }
}
