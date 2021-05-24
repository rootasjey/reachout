import 'package:easy_localization/easy_localization.dart';
import 'package:rootasjey/components/animated_app_icon.dart';
import 'package:rootasjey/components/app_icon.dart';
import 'package:rootasjey/components/base_app_bar.dart';
import 'package:rootasjey/components/circle_button.dart';
import 'package:rootasjey/components/fade_in_y.dart';
import 'package:rootasjey/router/app_router.gr.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/state/user.dart';
import 'package:rootasjey/utils/app_storage.dart';
import 'package:rootasjey/utils/constants.dart';
import 'package:rootasjey/utils/fonts.dart';
import 'package:rootasjey/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supercharged/supercharged.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  DeleteAccountPageState createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  bool isDeleting = false;
  bool isCompleted = false;

  double beginY = 10.0;

  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar(),
          body(),
        ],
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
    }

    return BasePageAppBar(
      expandedHeight: 90.0,
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: titleLeftPadding),
            child: CircleButton(
              onTap: context.router.pop,
              icon: Icon(
                Icons.arrow_back,
                color: stateColors.foreground,
              ),
            ),
          ),
          AppIcon(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            size: 30.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete accouunt',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                    color: stateColors.foreground,
                  ),
                ),
                Opacity(
                  opacity: .6,
                  child: Text(
                    'Well, this marks the end of the adventure',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: stateColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedView();
    }

    if (isDeleting) {
      return deletingView();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Icon(
                Icons.check,
                color: Colors.green.shade300,
                size: 80.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
              ),
              child: Text(
                'Your account has been successfuly deleted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'We hope to see you again',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 45.0,
              ),
              child: OutlinedButton(
                onPressed: () => context.router.navigate(HomePageRoute()),
                child: Opacity(
                  opacity: .6,
                  child: Text(
                    'Back home',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }

  Widget deletingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Deleting your data...',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: <Widget>[
              FadeInY(
                delay: 0.milliseconds,
                beginY: beginY,
                child: warningCard(),
              ),
              FadeInY(
                delay: 100.milliseconds,
                beginY: beginY,
                child: passwordInput(),
              ),
              FadeInY(
                delay: 200.milliseconds,
                beginY: beginY,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: validationButton(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/delete-user-light.png',
        width: 100.0,
      ),
    );
  }

  Widget passwordInput() {
    return SizedBox(
      width: 500.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Enter your password',
            ),
            autofocus: true,
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            onFieldSubmitted: (value) => deleteAccountProcess(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Password login cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget textTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Text(
        'Delete account',
        style: TextStyle(
          fontSize: 35.0,
        ),
      ),
    );
  }

  Widget validationButton() {
    return OutlinedButton(
      onPressed: () => deleteAccountProcess(),
      style: OutlinedButton.styleFrom(
        primary: Colors.red,
      ),
      child: SizedBox(
        width: 260.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'DELETE ACCOUNT',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget warningCard() {
    return Container(
      width: 500.0,
      padding: EdgeInsets.only(
        top: 60.0,
        bottom: 40.0,
      ),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          title: Row(
            children: <Widget>[
              Opacity(
                opacity: 0.6,
                child: Icon(
                  Icons.warning,
                  color: stateColors.secondary,
                ),
              ),
              Padding(padding: const EdgeInsets.only(left: 30.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Opacity(
                      opacity: .8,
                      child: Text("are_you_sure".tr()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "action_irreversible".tr(),
                        style: FontsUtils.mainStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(
                    "account_deletion_after".tr(),
                    style: FontsUtils.mainStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: <Widget>[
                    Divider(
                      color: stateColors.secondary,
                      thickness: 1.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("account_deletion_point_1".tr()),
                          Padding(padding: const EdgeInsets.only(top: 15.0)),
                          Text("account_deletion_point_2".tr()),
                          Padding(padding: const EdgeInsets.only(top: 15.0)),
                          Text("account_deletion_point_3".tr()),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void deleteAccountProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() => isDeleting = true);

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() => isDeleting = false);
        context.router.navigate(SigninPageRoute());
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);
      final idToken = await userAuth.getIdToken();

      final respDelAcc = await stateUser.deleteAccount(idToken);

      if (!respDelAcc.success) {
        final exception = respDelAcc.error;

        setState(() {
          isDeleting = false;
        });

        Snack.e(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
        );

        return;
      }

      await stateUser.signOut();
      stateUser.setUsername('');
      appStorage.clearUserAuthData();

      // PushNotifications.unlinkAuthUser();

      setState(() {
        isDeleting = false;
        isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isDeleting = false;
      });

      Snack.e(
        context: context,
        message: (error as PlatformException).message,
      );
    }
  }

  bool inputValuesOk() {
    if (password.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    return true;
  }
}
