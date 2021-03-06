import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/router/app_router.gr.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/state/user.dart';
import 'package:unicons/unicons.dart';

class AvatarMenu extends StatelessWidget {
  final bool isSmall;
  final EdgeInsets padding;

  const AvatarMenu({
    Key key,
    this.isSmall = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      padding: padding,
      child: PopupMenuButton<PageRouteInfo>(
        icon: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          child: CircleAvatar(
            backgroundColor: stateColors.lightBackground,
            radius: 20.0,
            backgroundImage: NetworkImage(
              stateUser.userFirestore.pp.url.edited,
            ),
          ),
        ),
        onSelected: (route) {
          if (route.routeName == SignOutRoute.name) {
            stateUser.signOut(context: context);
            return;
          }

          context.router.root.push(route);
        },
        itemBuilder: itemBuilder,
      ),
    );
  }

  List<PopupMenuEntry<PageRouteInfo<dynamic>>> itemBuilder(
      BuildContext context) {
    return [
      if (isSmall) ...[
        PopupMenuItem(
          value: DashboardPageRoute(
            children: [
              DashPostsRouter(
                children: [
                  NewPostPageRoute(),
                ],
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(UniconsLine.plus),
            title: Text(
              "post_new".tr(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: DashboardPageRoute(children: [
            DashProjectsRouter(children: [
              NewProjectPageRoute(),
            ]),
          ]),
          child: ListTile(
            leading: Icon(UniconsLine.plus),
            title: Text(
              "project_new".tr(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: SearchPageRoute(),
          child: ListTile(
            leading: Icon(UniconsLine.search),
            title: Text(
              "search".tr(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      PopupMenuItem(
        value: DashboardPageRoute(children: [
          DashPostsRouter(
            children: [
              MyPostsPageRoute(),
            ],
          )
        ]),
        child: ListTile(
          leading: Icon(UniconsLine.newspaper),
          title: Text(
            "posts_my".tr(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: DashboardPageRoute(children: [
          DashProjectsRouter(
            children: [
              MyProjectsPageRoute(),
            ],
          )
        ]),
        child: ListTile(
          leading: Icon(UniconsLine.apps),
          title: Text(
            "projects_my".tr(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: DashboardPageRoute(children: [DashProfileRouter()]),
        child: ListTile(
          leading: Icon(UniconsLine.user),
          title: Text(
            "profile_my".tr(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: SignOutRoute(),
        child: ListTile(
          leading: Icon(UniconsLine.sign_left),
          title: Text(
            "signout".tr(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ];
  }
}
