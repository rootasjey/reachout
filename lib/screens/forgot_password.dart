import 'package:rootasjey/actions/users.dart';
import 'package:rootasjey/components/fade_in_x.dart';
import 'package:rootasjey/components/fade_in_y.dart';
import 'package:rootasjey/components/loading_animation.dart';
import 'package:rootasjey/router/app_router.gr.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

import '../components/home_app_bar.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = '';

  bool isCompleted = false;
  bool isLoading = false;

  final passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          HomeAppBar(
            title: Text("Recover account"),
            automaticallyImplyLeading: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0, bottom: 300.0),
                    child: SizedBox(
                      width: 320,
                      child: body(),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedContainer();
    }

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          textTitle: 'Sending email...',
        ),
      );
    }

    return idleContainer();
  }

  Widget completedContainer() {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Icon(
            Icons.check_circle,
            size: 80.0,
            color: Colors.green,
          ),
        ),
        Container(
          width: width > 400.0 ? 320.0 : 280.0,
          // padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                child: Text(
                  "A password reset link has been sent to your mail box",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Opacity(
                opacity: .6,
                child: Text('Please check your spam folder too'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 55.0,
          ),
          child: TextButton(
            onPressed: () {
              context.router.navigate(HomeRoute());
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                'Return to home',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        validationButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 40.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              onFieldSubmitted: (value) => sendResetLink(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Email login cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (context.router.stack.length > 1)
          FadeInX(
            beginX: 10.0,
            delay: 100.milliseconds,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: IconButton(
                onPressed: () => context.router.pop(),
                icon: Icon(Icons.arrow_back),
              ),
            ),
          ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeInY(
                beginY: 50.0,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              FadeInY(
                beginY: 50.0,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'We will send a reset link to your mail box',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: ElevatedButton(
          onPressed: sendResetLink,
          style: ElevatedButton.styleFrom(
            primary: stateColors.accent,
            textStyle: TextStyle(
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('SEND LINK'),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(Icons.send),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool inputValuesOk() {
    if (email.isEmpty) {
      Snack.e(
        context: context,
        message: "Email field can't be empty. Please enter your email.",
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(email)) {
      Snack.e(
        context: context,
        message: "The value specified is not a valid email",
      );

      return false;
    }

    return true;
  }

  void sendResetLink() async {
    if (!inputValuesOk()) {
      return;
    }
    try {
      setState(() {
        isLoading = true;
        isCompleted = false;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        isLoading = false;
        isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });

      Snack.e(
        context: context,
        message: "Sorry, this email doesn't exist.",
      );
    }
  }
}
