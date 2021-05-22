import 'package:flutter/material.dart';
import 'package:rootasjey/components/landing_contact.dart';
import 'package:rootasjey/components/landing_github.dart';
import 'package:rootasjey/components/landing_hero.dart';
import 'package:rootasjey/components/landing_inside.dart';
import 'package:rootasjey/components/landing_posts.dart';
import 'package:rootasjey/components/landing_quote.dart';
import 'package:rootasjey/components/landing_work_us.dart';
import 'package:rootasjey/components/main_app_bar.dart';
import 'package:rootasjey/components/recent_posts.dart';
import 'package:rootasjey/components/footer.dart';
import 'package:rootasjey/components/home_app_bar.dart';
import 'package:rootasjey/components/home_nav_bar.dart';
import 'package:rootasjey/components/home_presentation.dart';
import 'package:rootasjey/components/newsletter.dart';
import 'package:rootasjey/components/recent_activities.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:supercharged/supercharged.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return newUI();
  }

  Widget newUI() {
    return Scaffold(
      backgroundColor: stateColors.newLightBackground,
      body: CustomScrollView(
        controller: scrollController,
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
              Footer(pageScrollController: scrollController),
            ]),
          ),
        ],
      ),
    );
  }

  Widget oldUI() {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          HomeAppBar(
            onTapIconHeader: () {
              scrollController.animateTo(
                0,
                duration: 250.milliseconds,
                curve: Curves.decelerate,
              );
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              HomePresentation(),
              HomeNavBar(),
              RecentActivities(),
              RecentPosts(),
              Newsletter(),
              Footer(pageScrollController: scrollController),
            ]),
          ),
        ],
      ),
    );
  }
}