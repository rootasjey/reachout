import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/components/landing_contact.dart';
import 'package:rootasjey/components/landing_github.dart';
import 'package:rootasjey/components/landing_hero.dart';
import 'package:rootasjey/components/landing_inside.dart';
import 'package:rootasjey/components/landing_posts.dart';
import 'package:rootasjey/components/landing_quote.dart';
import 'package:rootasjey/components/landing_work_us.dart';
import 'package:rootasjey/components/main_app_bar.dart';
import 'package:rootasjey/components/footer.dart';
import 'package:supercharged/supercharged.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  bool _isFabVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floattingActionButton(),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            MainAppBar(),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                LandingHero(),
                LandingGitHub(),
                LandingPosts(),
                LandingQuote(),
                LandingInside(),
                LandingWorkUs(),
                LandingContact(),
                Footer(pageScrollController: _scrollController),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget floattingActionButton() {
    if (!_isFabVisible) {
      return Container();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 500.milliseconds,
          curve: Curves.bounceIn,
        );
      },
      label: Text("scroll_to_top".tr()),
    );
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }

    return false;
  }
}
