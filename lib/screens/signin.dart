
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/actions/users.dart';
import 'package:rootasjey/components/loading_animation.dart';
import 'package:rootasjey/rooter/route_names.dart';
import 'package:rootasjey/rooter/router.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/state/user_state.dart';
import 'package:rootasjey/utils/app_local_storage.dart';
import 'package:rootasjey/utils/snack.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = '';
  String password = '';

  bool isCheckingAuth = false;
  bool isCompleted    = false;
  bool isSigningIn    = false;

  final passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
    passwordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 100.0,
                  bottom: 300.0,
                ),
                child: SizedBox(
                  width: 320.0,
                  child: body(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedContainer();
    }

    if (isSigningIn) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          textTitle: 'Signing in...',
        ),
      );
    }

    return idleContainer();
  }

  Widget completedContainer() {
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

        Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
          child: Text(
            'You are now logged in!',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 15.0,),
          child: FlatButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                DashboardRoute,
              );
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                'Go to your dashboard',
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
        passwordInput(),
        forgotPassword(),
        validationButton(),
        noAccountButton(),
      ],
    );
  }

  Widget emailInput() {
    return Padding(
      padding: EdgeInsets.only(
        top: 80.0,
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
            validator: (value) {
              if (value.isEmpty) {
                return 'Email login cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget forgotPassword() {
    return FlatButton(
      onPressed: () {
        FluroRouter.router.navigateTo(context, ForgotPasswordRoute);
      },
      child: Opacity(
        opacity: .6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              "I forgot my password",
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget header() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20.0,),
          child: IconButton(
            onPressed: () {
              FluroRouter.router.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Opacity(
              opacity: .6,
              child: Text(
                'Connect to your existing account'
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget noAccountButton() {
    return FlatButton(
      onPressed: () async {
        await FluroRouter.router.navigateTo(
          context,
          SignupRoute,
        );

        if (userState.isUserConnected) {
          await FluroRouter.router.navigateTo(
            context,
            DashboardRoute,
            replace: true,
          );
        }
      },
      child: Opacity(
        opacity: .6,
        child: Text(
          "I don't have an account",
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      )
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.0,
        left: 15.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: passwordNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Password',
            ),
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
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

  Widget validationButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: RaisedButton(
        onPressed: () => signIn(),
        color: stateColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
        ),
        child: Container(
          width: 250.0,
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SIGN IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Icon(Icons.arrow_forward, color: Colors.white,),
              )
            ],
          ),
        ),
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await userState.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth != null) {
        userState.setUserConnected();
        FluroRouter.router.navigateTo(context, DashboardRoute);
      }

    } catch (error) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  bool inputValuesOk() {
    if (!checkEmailFormat(email)) {
      showSnack(
        context: context,
        message: "The value specified is not a valid email",
        type: SnackType.error,
      );

      return false;
    }

    if (password.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }

  void signIn() async {
    if (!inputValuesOk()) { return; }

    setState(() {
      isSigningIn = true;
    });

    try {
      final authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

      if (authResult.user == null) {
        showSnack(
          context: context,
          type: SnackType.error,
          message: 'The password is incorrect or the user does not exists.',
        );

        return;
      }

      appLocalStorage.setCredentials(
        email: email,
        password: password,
      );

      userState.setUserConnected();

      setState(() {
        isSigningIn = false;
        isCompleted = true;
      });

      await userGetAndSetAvatarUrl(authResult);

      FluroRouter.router.navigateTo(
        context,
        RootRoute,
        replace: true,
      );

    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        type: SnackType.error,
        message: 'The password is incorrect or the user does not exists.',
      );

      setState(() {
        isSigningIn = false;
      });
    }
  }
}
