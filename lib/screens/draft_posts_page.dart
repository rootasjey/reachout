import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/components/min_post_card.dart';
import 'package:rootasjey/components/sliver_edge_padding.dart';
import 'package:rootasjey/components/sliver_empty_view.dart';
import 'package:rootasjey/router/app_router.gr.dart';
import 'package:rootasjey/state/user.dart';
import 'package:rootasjey/types/post.dart';
import 'package:rootasjey/utils/app_logger.dart';
import 'package:rootasjey/utils/flash_helper.dart';
import 'package:rootasjey/utils/fonts.dart';
import 'package:rootasjey/utils/snack.dart';
import 'package:unicons/unicons.dart';

class DraftPostsPage extends StatefulWidget {
  @override
  _DraftPostsPageState createState() => _DraftPostsPageState();
}

class _DraftPostsPageState extends State<DraftPostsPage> {
  final _posts = <Post>[];
  final _limit = 10;

  bool _hasNext = true;
  bool _isLoading = false;

  DocumentSnapshot _lastDocumentSnapshot;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: CustomScrollView(
        slivers: [
          header(context.tabsRouter),
          body(),
          SliverEdgePadding(),
        ],
      ),
    );
  }

  Widget body() {
    Widget child;

    if (!_isLoading && _posts.isEmpty) {
      child = SliverEmptyView();
    } else {
      child = postsListView();
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 90.0,
        right: 90.0,
        bottom: 300.0,
      ),
      sliver: child,
    );
  }

  PopupMenuButton buildPopupMenuButton(Post post, int index) {
    return PopupMenuButton<String>(
      icon: Opacity(
        opacity: 0.6,
        child: Icon(UniconsLine.ellipsis_h),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            goToEditPostPage(post);
            break;
          case 'delete':
            confirmDeletePost(index);
            break;
          case 'publish':
            publish(index);
            break;
          default:
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(UniconsLine.edit),
            title: Text("edit".tr()),
          ),
        ),
        PopupMenuItem(
          value: 'publish',
          child: ListTile(
            leading: Icon(UniconsLine.cloud_upload),
            title: Text("publish".tr()),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(UniconsLine.trash),
            title: Text("delete".tr()),
          ),
        ),
      ],
    );
  }

  Widget header(TabsRouter tabsRouter) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.all(80.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: IconButton(
                  onPressed: context.router.pop,
                  icon: Icon(UniconsLine.arrow_left),
                ),
              ),
              headerSection(
                textTitle: "drafts".tr(),
                index: 0,
                tabsRouter: tabsRouter,
              ),
              headerSection(
                textTitle: "published".tr(),
                index: 1,
                tabsRouter: tabsRouter,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget headerSection({
    @required String textTitle,
    @required int index,
    @required TabsRouter tabsRouter,
  }) {
    final isSelected = index == tabsRouter.activeIndex;

    return InkWell(
      onTap: () => tabsRouter.setActiveIndex(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.5,
          child: Text(
            textTitle,
            style: FontsUtils.mainStyle(
              fontSize: 40.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  Widget postsListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = _posts.elementAt(index);
          final popupButton = buildPopupMenuButton(post, index);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MinPostCard(
                post: post,
                width: 800.0,
                onTap: () => goToEditPostPage(post),
                contentPadding: const EdgeInsets.all(24.0),
                popupMenuButton: popupButton,
              ),
              Divider(height: 40.0),
            ],
          );
        },
        childCount: _posts.length,
      ),
    );
  }

  void confirmDeletePost(int index) {
    FlashHelper.deleteDialog(
      context,
      message: "post_delete_description".tr(),
      onConfirm: () {
        deletePost(index);
      },
    );
  }

  void deletePost(int index) async {
    setState(() => _isLoading = true);

    final removedPost = _posts.removeAt(index);

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(removedPost.id)
          .delete();
    } catch (error) {
      appLogger.e(error);

      Snack.e(
        context: context,
        message: "post_delete_failed".tr(),
      );

      setState(() {
        _posts.insert(index, removedPost);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void fetch() async {
    setState(() {
      _posts.clear();
      _isLoading = true;
    });

    try {
      final userAuth = stateUser.userAuth;
      final uid = userAuth.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('published', isEqualTo: false)
          .where('author.id', isEqualTo: uid)
          .limit(_limit)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        _posts.add(Post.fromJSON(data));
      });

      setState(() {
        _isLoading = false;
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      appLogger.e(error);
      setState(() => _isLoading = false);
    }
  }

  void fetchMore() async {
    if (_lastDocumentSnapshot == null || !_hasNext || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userAuth = stateUser.userAuth;
      final uid = userAuth.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('published', isEqualTo: false)
          .where('author.id', isEqualTo: uid)
          .limit(_limit)
          .startAfterDocument(_lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        _posts.add(Post.fromJSON(data));
      });

      setState(() {
        _isLoading = false;
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      appLogger.e(error);
      setState(() => _isLoading = false);
    }
  }

  void goToEditPostPage(Post post) async {
    await context.router.push(
      EditPostPageRoute(postId: post.id),
    );

    fetch();
  }

  bool onNotification(ScrollNotification scrollNotification) {
    final double current = scrollNotification.metrics.pixels;
    final double max = scrollNotification.metrics.maxScrollExtent;

    if (current < max - 300.0) {
      return false;
    }

    fetchMore();
    return false;
  }

  void publish(int index) async {
    setState(() => _isLoading = true);

    final removedPost = _posts.removeAt(index);

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(removedPost.id)
          .update({
        'published': true,
      });

      setState(() => _isLoading = false);
    } catch (error) {
      appLogger.e(error);

      setState(() {
        _posts.insert(index, removedPost);
      });
    }
  }
}
