import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/components/home_app_bar.dart';
import 'package:rootasjey/rooter/route_names.dart';
import 'package:rootasjey/rooter/router.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/state/user_state.dart';
import 'package:rootasjey/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class EditPost extends StatefulWidget {
  final String postId;

  EditPost({
    this.postId = '',
  });

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  bool isLoading = false;
  bool isSaving = false;
  bool hasError = false;

  DocumentSnapshot postSnapshot;

  final availableLang = ['en', 'fr'];
  final clearFocusNode  = FocusNode();
  final postFocusNode   = FocusNode();
  final contentController  = TextEditingController();
  final titleFocusNode  = FocusNode();
  final titleController = TextEditingController();

  String postTitle    = '';
  String postContent  = '';
  String lang         = 'en';
  String jwt = '';

  Timer saveTitleTimer;
  Timer saveContentTimer;

  @override
  void initState() {
    super.initState();
    initAndCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircularProgressIndicator(strokeWidth: 2.0,),
                  ),

                Opacity(
                  opacity: 0.6,
                  child: Text(
                    isSaving
                      ? 'Saving...'
                      : (postTitle.isEmpty ? 'Edit Post' : postTitle),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: stateColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (hasError) {
      return errorView();
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(
            top: 40.0,
            bottom: 400.0,
          ),
          child: Column(
            children: [
              actionsInput(),
              titleInput(),
              contentInput(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(
            top: 200.0,
            left: 40.0,
            right: 40.0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(
                    Icons.sentiment_neutral,
                    color: Colors.pink,
                    size: 80.0,
                  ),
                ),
              ),

              Container(
                width: 600.0,
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                ),
                child: Opacity(
                  opacity: 0.7,
                  child: Text(
                    "An error occurred. Maybe the post doesn't exist anymore or there's a network issue.",
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                ),
              ),

              OutlineButton.icon(
                onPressed: () => FluroRouter.router.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.pink),
                label: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'Navigate back',
                    style: TextStyle(
                        fontSize: 16.0,
                      ),
                  ),
                )
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(
            top: 200.0,
            left: 40.0,
            right: 40.0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                ),
                child: CircularProgressIndicator(),
              ),

              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 30.0,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget titleInput() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 110.0,
        top: 60.0,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              onPressed: () => FluroRouter.router.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),

          Expanded(
            child: Container(
              width: 700.0,
              child: TextField(
                maxLines: 1,
                autofocus: true,
                focusNode: titleFocusNode,
                controller: titleController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (newValue) {
                  postTitle = newValue;

                  if (saveTitleTimer != null) {
                    saveTitleTimer.cancel();
                  }

                  saveTitleTimer = Timer(
                    1.seconds,
                    () => saveTitle()
                  );
                },
                style: TextStyle(
                  fontSize: 42.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Post Title...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget contentInput() {
    return Container(
      width: 700.0,
      child: TextField(
        maxLines: null,
        autofocus: false,
        focusNode: postFocusNode,
        controller: contentController,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (newValue) {
          postContent = newValue;

          if (saveContentTimer != null) {
            saveContentTimer.cancel();
          }

          saveContentTimer = Timer(
            1.seconds,
            () => saveContent()
          );
        },
        style: TextStyle(
          fontSize: 22.0,
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.edit),
          hintText: "Once upon a time...",
          border: OutlineInputBorder(
            borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }

  Widget actionsInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 120.0),
      child: Row(
        children: <Widget>[
          langSelect(),

          Padding(padding: const EdgeInsets.only(left: 20.0),),

          FlatButton.icon(
            focusNode: clearFocusNode,
            onPressed: () {
              postContent = '';
              contentController.clear();
              postFocusNode.requestFocus();
            },
            icon: Opacity(opacity: 0.6, child: Icon(Icons.clear)),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                'Clear content',
              ),
            )
          ),

          Padding(padding: const EdgeInsets.only(left: 20.0),),

          FlatButton.icon(
            focusNode: postFocusNode,
            onPressed: () {
              saveTitle();
              saveContent();
            },
            icon: Opacity(opacity: 0.6, child: Icon(Icons.save)),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                'Save draft',
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget langSelect() {
    return DropdownButton<String>(
      value: lang,
      style: TextStyle(
        color: stateColors.primary,
        fontSize: 20.0,
      ),
      icon: Icon(Icons.language),
      iconEnabledColor: stateColors.primary,
      onChanged: (newValue) {
        setState(() {
          lang = newValue;
        });
      },
      items: availableLang
        .map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.toUpperCase()),
          );
        }).toList(),
    );
  }

  Future<bool> checkAuth() async {
    try {
      final userAuth = await userState.userAuth;
      if (userAuth != null) { return true; }

      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;

    } catch (error) {
      debugPrint(error.toString());
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }
  }

  Future fetchMeta() async {
    try {
      postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();

      jwt = await FirebaseAuth.instance
        .currentUser
        .getIdToken();

      setState(() {
        postTitle = postSnapshot.data()['title'];
        titleController.text = postTitle;
      });

    } catch(error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });

      debugPrint(error.toSring());

      showSnack(
        context: context,
        message: "There was an error while saving.\n${error.toString()}",
        type: SnackType.error,
      );
    }
  }

  Future fetchContent() async {
    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'posts-fetch',
      );

      final response = await callable.call({
        'postId': widget.postId,
        'jwt': jwt,
      });

      setState(() {
        postContent = response.data['post'];
        contentController.text = postContent;
      });

    } catch(error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint(error.toSring());

      showSnack(
        context: context,
        message: "There was an error while fetching the post.\n${error.toString()}",
        type: SnackType.error,
      );
    }
  }

  void initAndCheck() async {
    if (widget.postId.isEmpty) {
      FluroRouter.router.navigateTo(context, RootRoute);
      return;
    }

    final result = await checkAuth();
    if (!result) { return; }

    setState(() => isLoading = true);

    await fetchMeta();
    await fetchContent();

    setState(() => isLoading = false);
  }

  void saveTitle() async {
    try {
      await postSnapshot
        .reference
        .update({'title': postTitle});

      setState(() => isSaving = false);

    } catch (error) {
      debugPrint(error.toString());
      setState(() => isSaving = false);
    }
  }

  void saveContent() async {
    setState(() => isSaving = true);

    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(functionName: 'posts-save ');

      final resp = await callable.call({
        'postId'  : postSnapshot.id,
        'jwt'     : jwt,
        'content' : postContent,
      });

      print('success: ${resp.data['success']}');
      bool success = resp.data['success'];

      if (!success) {
        throw ErrorDescription(resp.data['error']);
      }

      setState(() => isSaving = false);

    } catch (error) {
      debugPrint(error.toString());
      setState(() => isSaving = false);
    }
  }
}